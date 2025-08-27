#!/bin/bash

source "./colors.sh"

SSH_DIR="$HOME/.ssh"
NVIM_DIR="$HOME/.config/nvim"
WP_DIR="$HOME/data/img/wp"
SWAY_DIR="$HOME/.config/sway"
WAYBAR_DIR="$HOME/.config/waybar"

COMMON_BCKP_DIR="./common"
SSH_BCKP_DIR="$COMMON_BCKP_DIR/ssh"
GIT_BCKP_DIR="$COMMON_BCKP_DIR/git"
NVIM_BCKP_DIR="$COMMON_BCKP_DIR/nvim"
WP_BCKP_DIR="$COMMON_BCKP_DIR/wp"
SWAY_BCKP_DIR="./sway"
WAYBAR_BCKP_DIR="$COMMON_BCKP_DIR/waybar"

mkdir -p "$COMMON_BCKP_DIR"

echo -e "${BLUE}Backing up SSH configuration...${RESET}"
if [ -d $SSH_DIR ]; then
  if [ -f "$SSH_DIR/config" ]; then
    mkdir -p "$SSH_BCKP_DIR"
    if cp "$SSH_DIR/config" "$SSH_BCKP_DIR/"; then
      echo -e "${GREEN}Done!${RESET}"
    else
      echo -e "${RED}SSH configuration could not be backed up.${RESET}"
      exit 1
    fi
  else
    echo -e "${YELLOW}No SSH configuration found.${RESET}"
  fi
else
    echo -e "${YELLOW}No SSH directory found.${RESET}"
fi

echo -e "${BLUE}Backing up Git configuration...${RESET}"
if [ -f "$HOME/.gitconfig" ]; then
  mkdir -p "$GIT_BCKP_DIR"
  if cp "$HOME/.gitconfig" "$GIT_BCKP_DIR/"; then
    echo -e "${GREEN}Done!${RESET}"
  else
    echo -e "${RED}Git configuration could not be backed up.${RESET}"
    exit 1
  fi
else
  echo -e "${YELLOW}No Git configuration found.${RESET}"
fi

echo -e "${BLUE}Backing up Neovim dotfiles...${RESET}"
if [ -d $NVIM_DIR ]; then
  if [ -d $NVIM_BCKP_DIR ]; then
    rm -rf "$NVIM_BCKP_DIR"
  fi
  if cp -r "$NVIM_DIR" "$NVIM_BCKP_DIR"; then
    echo -e "${GREEN}Done!${RESET}"
  else
    echo -e "${RED}Neovim dotfiles could not be backed up.${RESET}"
    exit 1
  fi
else
  echo -e "${YELLOW}No Neovim dotfiles were found.${RESET}"
fi

echo -e "${BLUE}Backing up wallpapers...${RESET}"
if [ -d $WP_DIR ]; then
  if [ -d $WP_BCKP_DIR ]; then
    rm -rf "$WP_BCKP_DIR"
  fi
  if cp -r "$WP_DIR" "$COMMON_BCKP_DIR"; then
    echo -e "${GREEN}Done!${RESET}"
  else
    echo -e "${RED}Wallpapers could not be backed up.${RESET}"
    exit 1
  fi
else
  echo -e "${YELLOW}No wallpapers directory was found.${RESET}"
fi

backup_waybar() {
  echo "Backing up config files for Waybar..."
  if [ -d $WAYBAR_DIR ]; then
    if [ -d $WAYBAR_BCKP_DIR ]; then
      rm -rf "$WAYBAR_BCKP_DIR"
    fi
    if cp -r "$WAYBAR_DIR" "$COMMON_BCKP_DIR"; then
      echo -e "${GREEN}Done!${RESET}"
    else
      echo -e "${RED}Waybar config could not be backed up."
      exit 1
    fi
  else
    echo -e "${YELLOW}No Waybar config directory was found.${RESET}"
  fi
}

backup_sway() {
  echo "Backing up config files for SwayWM..."
  if [ -d $SWAY_DIR ]; then
    if [ -d $SWAY_BCKP_DIR ]; then
      rm -rf "$SWAY_BCKP_DIR"
    fi
    if cp -r "$SWAY_DIR" .; then
      echo -e "${GREEN}Done!${RESET}"
    else
      echo -e "${RED}SwayWM config could not be backed up.${RESET}"
      exit 1
    fi
    backup_waybar
  else
    echo -e "${YELLOW}No SwayWM config directory was found.${RESET}"
  fi
}

echo -e "${BLUE}Backing up DE/WM config...${RESET}"
WM=$(fastfetch | grep -i "WM:" | awk '{print $2}')
case $WM in
  Sway)
    backup_sway
    ;;
  # TODO: Hyprland
  # TODO: KDE Plasma
  *)
    echo -e "${YELLOW}Unknown DE/WM detected: $WM${RESET}"
    ;;
esac
echo -e "${GREEN}Backup finished!${RESET}"
