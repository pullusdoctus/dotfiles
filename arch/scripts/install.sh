#!/bin/bash

set -e
source "./colors.sh"

echo -e "{$BLUE}=== Arch Linux Installation Script ==={$RESET}"
echo ""

config_dns() {
  echo -e "{$BLUE}=== Configuring DNS ==={$RESET}"
  echo "Setting up DNS servers (1.1.1.1, 4.4.4.4, 8.8.8.8)..."
  if [ -f /etc/resolv.conf ]; then
    sudo cp /etc/resolv.conf /etc/resolv.conf.backup
    echo -e "{$GREEN}Backed up existing resolv.conf{$RESET}"
  fi
  active_conn=$(nmcli -t -f NAME,DEVICE connection show --active | grep -v ':lo' | head -n1 | cut -d: -f1)
  if [ -z "$active_conn" ]; then
    echo -e "{$RED}No active NetworkManager connection found.{$RESET}"
    exit 1
  fi
  echo -e "{$GREEN}Active connection: $active_conn{$RESET}"
  # apply DNS
  sudo nmcli connection modify "$active_conn" ipv4.dns "1.1.1.1 4.4.4.4 8.8.8.8"
  sudo nmcli connection modify "$active_conn" ipv4.ignore-auto-dns yes
  # reset connection
  sudo nmcli connection down "$active_conn"
  sudo nmcli connection up "$active_conn"

  if [ $? -eq 0 ]; then
    echo -e "{$GREEN}DNS configuration applied successfully.{$RESET}"
  else
    echo -e "{$RED}Failed to apply DNS configuration.{$RESET}"
    exit 1
  fi
  echo ""
}

update_pkg_database() {
  echo "Updating package database..."
  if sudo pacman -Sy; then
    echo -e "{$GREEN}Package database updated successfully{$RESET}"
  else
    echo -e "{$RED}Failed to update package database{$RESET}"
    exit 1
  fi
  echo ""
}

enable_multilib() {
  echo -e "{$BLUE}=== Enabling Multilib Repository ==={$RESET}"
  echo "Enabling multilib in /etc/pacman.conf for Steam support..."
  sudo cp /etc/pacman.conf /etc/pacman.conf.backup
  echo -e "{$GREEN}Backed up pacman.conf{$RESET}"
  if grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo -e "{$GREEN}Multilib repository is already enabled{$RESET}"
  else
    sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
    if grep -q "^\[multilib\]" /etc/pacman.conf; then
      echo -e "{$GREEN}Multilib repository enabled successfully{$RESET}"
    else
      echo -e "{$RED}Failed to enable multilib repository{$RESET}"
      exit 1
    fi
  fi
  update_pkg_database
}

install_paru() {
  echo -e "{$BLUE}=== Installing paru AUR Helper ==={$RESET}"
  echo "Installing paru for AUR package management..."
  if command -v paru &> /dev/null; then
    echo -e "{$GREEN}paru is already installed{$RESET}"
  else
    echo "Installing prerequisites (base-devel, git)..."
    if sudo pacman -S --needed --noconfirm base-devel git; then
      echo -e "{$GREEN}Prerequisites installed successfully{$RESET}"
    else
      echo -e "{$RED}Failed to install prerequisites{$RESET}"
      exit 1
    fi
    echo "Cloning paru repository..."
    if git clone https://aur.archlinux.org/paru.git; then
      echo -e "{$GREEN}paru repository cloned successfully{$RESET}"
    else
      echo -e "{$RED}Failed to clone paru repository{$RESET}"
      exit 1
    fi
    echo "Building and installing paru..."
    cd paru
    if makepkg -si --noconfirm; then
      echo -e "{$GREEN}paru installed successfully{$RESET}"
    else
      echo -e "{$RED}Failed to build/install paru{$RESET}"
      exit 1
    fi
    cd ..
    rm -rf paru
    echo -e "{$GREEN}Cleaned up temporary files{$RESET}"
  fi
  echo ""
}

install_essentials() {
  echo -e "{$BLUE}=== Installing Essential Packages ==={$RESET}"
  echo "Installing neovim, git, ssh, zsh, 7zip, ark, C/C++ Python & Lua libraries, fastfetch, wl-clipboard, fonts, fcitx5, snapper..."
  if paru -S --needed --noconfirm neovim git openssh zsh p7zip ark base-devel clang gdb cmake lldb valgrind python python-pip pyenv python-poetry stylua luarocks unzip wget go ruby ruby-gems php composer npm julia tree-sitter python-neovim fd fastfetch wl-clipboard nerd-fonts ttf-jetbrains-mono ttf-hack noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-ms-win11-auto fcitx5-im fcitx5-mozc fcitx5-rime snapper; then
    echo -e "{$GREEN}Essential packages installed successfully{$RESET}"
  else
    echo -e "{$RED}Failed to install essential packages{$RESET}"
    exit 1
  fi
  echo ""
}

install_apps() {
  echo -e "{$BLUE}=== Installing Apps ==={$RESET}"
  echo "Installing Notion, Obsidian, Anki, Zotero, Spotify, Discord, WhatsApp, Telegram, Zen Browser, Chromium, LibreOffice, Okular, Gimp, feh, VLC, QBittorrent..."
  if paru -S --needed --noconfirm notion-app-electron obsidian anki-bin zotero-bin spotify-launcher discord zapzap telegram-desktop zen-browser-bin ungoogled-chromium libreoffice-fresh okular gimp feh vlc qbittorrent; then
    echo -e "{$GREEN}Apps installed successfully{$RESET}"
  else
    echo -e "{$RED}Failed to install apps{$RESET}"
    exit 1
  fi
  echo ""
}

install_games() {
  echo -e "{$BLUE}=== Installing Games ==={$RESET}"
  echo "Installing Steam, PrismLauncher, emulators, gamescope, mangohud..."
  if paru -S --needed --noconfirm steam prismlauncher mesen2-git ares-emu pcsx2 sameboy gamescope mangohud; then
    echo -e "{$GREEN}Games installed successfully{$RESET}"
  else
    echo -e "{$RED}Failed to install games{$RESET}"
    exit 1
  fi
  echo -e "{$BLUE}=== Installing Bottles ==={$RESET}"
  if flatpak install bottles; then
    echo -e "{$GREEN}Bottles installed succesfully{$RESET}"
  else
    echo -e "{$RED}Failed to install Bottles{$RESET}"
    exit 1
  fi
  echo ""
}

prompt_game_installation() {
  while true; do:
    echo "Do you want to install games on this machine? (y/n):"
    read answer
    answer=$(echo "$answer" | tr '[:upper]' '[:lower]')
    if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
      install_games
      break
    elif [[ "$answer" == "n" || "$answer" == "no" ]]; then
      echo "No games will be installed."
      echo ""
      break
    else
      echo "Make sure to answer with a valid input (y/n or yes/no)"
    fi
  done
}

setup_zsh() {
  echo -e "{$BLUE}=== Setting up ZSH with Oh-My-ZSH and Powerlevel10k ==={$RESET}"
  echo "Installing Oh-My-ZSH..."
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [ $? -eq 0 ]; then
      echo -e "{$GREEN}Oh-My-ZSH installed successfully{$RESET}"
    else
      echo -e "{$RED}Failed to install Oh-My-ZSH{$RESET}"
      exit 1
    fi
  else
      echo -e "{$GREEN}Oh-My-ZSH is already installed{$RESET}"
  fi
  echo "Installing Powerlevel10k theme..."
  if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ $? -eq 0 ]; then
      echo -e "{$GREEN}Powerlevel10k installed successfully{$RESET}"
    else
      echo -e "{$RED}Failed to install Powerlevel10k{$RESET}"
      exit 1
    fi
  else
    echo -e "{$GREEN}Powerlevel10k is already installed{$RESET}"
  fi
  echo "Configuring .zshrc..."
  if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "{$GREEN}Backed up existing .zshrc{$RESET}"
  fi
  sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
  echo "Changing default shell to zsh..."
  if [ "$SHELL" != "/bin/zsh" ]; then
    chsh -s /bin/zsh
    echo -e "{$GREEN}Default shell changed to zsh{$RESET}"
  else
    echo -e "{$GREEN}Zsh is already the default shell{$RESET}"
  fi
  echo -e "{$GREEN}ZSH setup completed!{$RESET}"
  echo "Run 'p10k configure' after restarting your terminal to configure Powerlevel10k"
  echo ""
}

install_hyprland() {
  echo -e "{$BLUE}=== Installing Hyprland Desktop Environment ==={$RESET}"
  echo "Installing Hyprland and related packages..."
  if paru -S --needed --noconfirm hyprland mako ghostty uwsm dolphin wofi xdg-desktop-portal-hyprland qt5-wayland qt6-wayland polkit-kde-agent grim slurp hyprpaper hyprpicker pipewire wireplumber waybar; then
    echo -e "{$GREEN}Hyprland and related packages installed successfully{$RESET}"
  else
    echo -e "{$RED}Failed to install Hyprland packages{$RESET}"
    exit 1
  fi
  echo ""
}

# ===========================================================
# main:
echo "Starting Arch Linux installation setup..."
echo ""

config_dns
enable_multilib
install_paru
install_essentials
install_apps
prompt_game_installation
setup_zsh # TODO: rice and move to restore script
install_hyprland

if [ -f "./restore.sh" ]; then
  bash ./restore.sh
else
  echo -e "{$RED}Warning: restore.sh not found{$RESET}"
fi

echo ""
echo -e "{$BLUE}=== Configuration Summary ==={$RESET}"
echo "Desktop Environment: Hyprland"
echo "Shell: ZSH with Oh-My-ZSH and Powerlevel10k"
echo "AUR Helper: paru"
echo ""

echo -e "{$GREEN}Installation completed successfully!{$RESET}"
echo "Please reboot and run 'p10k configure' to set up Powerlevel10k theme"
