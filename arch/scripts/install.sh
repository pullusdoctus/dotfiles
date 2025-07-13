#!/bin/bash

# Arch Linux Installation Script

set -e  # Exit on any error

echo -e "\033[34m=== Arch Linux Installation Script ===\033[0m"
echo ""

mount_drives() {
	echo -e "\033[34m=== Mounting Drives ===\033[0m"
	# Define drive mappings
	declare -A DRIVES=(
	["/dev/sda1"]="$HOME/data"
	["/dev/sdb1"]="$HOME/media"
	["/dev/nvme0n1"]="$HOME/games"
	)
	# Create mount points and mount drives
	for device in "${!DRIVES[@]}"; do
		mount_point="${DRIVES[$device]}"
		echo "Processing $device -> $mount_point"
		# Check if device exists
		if [ ! -b "$device" ]; then
			echo -e "\033[33mWarning: Device $device not found, skipping...\033[0m"
			continue
		fi
		# Create mount point if it doesn't exist
		if [ ! -d "$mount_point" ]; then
			echo "Creating mount point: $mount_point"
			mkdir -p "$mount_point"
			if [ $? -eq 0 ]; then
				echo -e "\033[32mCreated mount point $mount_point\033[0m"
			else
				echo -e "\033[31mFailed to create mount point $mount_point\033[0m"
				continue
			fi
		else
			echo -e "\033[32mMount point $mount_point already exists\033[0m"
		fi
		# Check if already mounted
		if mountpoint -q "$mount_point"; then
			echo -e "\033[32m$mount_point is already mounted\033[0m"
		else
			# Mount the device
			echo "Mounting $device to $mount_point"
			sudo mount "$device" "$mount_point"
			if [ $? -eq 0 ]; then
				echo -e "\033[32mSuccessfully mounted $device to $mount_point\033[0m"
			else
				echo -e "\033[31mFailed to mount $device to $mount_point\033[0m"
				continue
			fi
		fi
		# Set proper ownership
		echo "Setting ownership of $mount_point to $USER"
		sudo chown "$USER:$USER" "$mount_point" 2>/dev/null || true
		# Get UUID of the device for fstab entry
		UUID=$(sudo blkid -s UUID -o value "$device")
		if [ -z "$UUID" ]; then
			echo -e "\033[33mWarning: Could not get UUID for $device, using device path instead\033[0m"
			DEVICE_ID="$device"
		else
			DEVICE_ID="UUID=$UUID"
			echo "Found UUID for $device: $UUID"
		fi
		# Get filesystem type
		FSTYPE=$(sudo blkid -s TYPE -o value "$device")
		if [ -z "$FSTYPE" ]; then
			echo -e "\033[33mWarning: Could not detect filesystem type for $device, assuming ext4\033[0m"
			FSTYPE="ext4"
		else
			echo "Detected filesystem type for $device: $FSTYPE"
		fi
		# Create fstab entry
		FSTAB_ENTRY="$DEVICE_ID $mount_point $FSTYPE defaults,nofail 0 2"
		# Check if entry already exists in fstab
		if grep -q "$mount_point" /etc/fstab; then
			echo -e "\033[33mEntry for $mount_point already exists in /etc/fstab\033[0m"
			# Show existing entry
			existing_entry=$(grep "$mount_point" /etc/fstab)
			echo "Existing entry: $existing_entry"
			# Ask if user wants to update it
			read -p "Do you want to update this entry? (y/N): " -n 1 -r
			echo
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				# Backup fstab
				sudo cp /etc/fstab "/etc/fstab.backup.$(date +%Y%m%d_%H%M%S)"
				echo -e "\033[32mBacked up /etc/fstab\033[0m"
				# Remove old entry and add new one
				sudo sed -i "\|$mount_point|d" /etc/fstab
				echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab > /dev/null
				echo -e "\033[32mUpdated fstab entry for $mount_point\033[0m"
			fi
		else
			# Backup fstab before making changes
			sudo cp /etc/fstab "/etc/fstab.backup.$(date +%Y%m%d_%H%M%S)"
			echo -e "\033[32mBacked up /etc/fstab\033[0m"
			# Add entry to fstab
			echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab > /dev/null
			echo -e "\033[32mAdded fstab entry: $FSTAB_ENTRY\033[0m"
		fi
		echo ""
	done
	# Test fstab entries
	echo "Testing fstab configuration..."
	if sudo mount -a; then
		echo -e "\033[32mAll fstab entries are valid\033[0m"
	else
		echo -e "\033[31mError: Some fstab entries may be invalid\033[0m"
		echo -e "\033[33mPlease check /etc/fstab manually\033[0m"
	fi
	# Show current mounts
	echo -e "\033[34mCurrent mount status:\033[0m"
	for mount_point in "$HOME/data" "$HOME/media" "$HOME/games"; do
		if mountpoint -q "$mount_point" 2>/dev/null; then
			device=$(df "$mount_point" | awk 'NR==2 {print $1}')
			usage=$(df -h "$mount_point" | awk 'NR==2 {print $5}')
			echo -e "\033[32m✓ $mount_point is mounted ($device, $usage used)\033[0m"
		else
			echo -e "\033[31m✗ $mount_point is not mounted\033[0m"
		fi
	done
	echo -e "\033[32mDrive setup completed\033[0m"
	echo ""
}

config_dns() {
    echo -e "\033[34m=== Configuring DNS ===\033[0m"
    echo "Setting up DNS servers (1.1.1.1, 4.4.4.4, 8.8.8.8)..."
    # Backup existing resolv.conf if it exists
    if [ -f /etc/resolv.conf ]; then
        sudo cp /etc/resolv.conf /etc/resolv.conf.backup
        echo -e "\033[32mBacked up existing resolv.conf\033[0m"
    fi
     # Detect active connection
    active_conn=$(nmcli -t -f NAME,DEVICE connection show --active | grep -v ':lo' | head -n1 | cut -d: -f1)
    if [ -z "$active_conn" ]; then
        echo -e "\033[31mNo active NetworkManager connection found.\033[0m"
        exit 1
    fi
    echo -e "\033[32mActive connection: $active_conn\033[0m"
    # Apply DNS servers to the active connection
    sudo nmcli connection modify "$active_conn" ipv4.dns "1.1.1.1 4.4.4.4 8.8.8.8"
    sudo nmcli connection modify "$active_conn" ipv4.ignore-auto-dns yes
    # Reactivate connection
    sudo nmcli connection down "$active_conn"
    sudo nmcli connection up "$active_conn"

    if [ $? -eq 0 ]; then
        echo -e "\033[32mDNS configuration applied successfully.\033[0m"
    else
        echo -e "\033[31mFailed to apply DNS configuration.\033[0m"
        exit 1
    fi
    echo ""
}

update_pkg_database() {
    echo "Updating package database..."
    if sudo pacman -Sy; then
        echo -e "\033[32mPackage database updated successfully\033[0m"
    else
        echo -e "\033[31mFailed to update package database\033[0m"
        exit 1
    fi
    echo ""
}

enable_multilib() {
    echo -e "\033[34m=== Enabling Multilib Repository ===\033[0m"
    echo "Enabling multilib in /etc/pacman.conf for Steam support..."
    # Backup pacman.conf
    sudo cp /etc/pacman.conf /etc/pacman.conf.backup
    echo -e "\033[32mBacked up pacman.conf\033[0m"
    # Check if multilib is already enabled
    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo -e "\033[32mMultilib repository is already enabled\033[0m"
    else
        # Enable multilib by uncommenting the lines
        sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
        if grep -q "^\[multilib\]" /etc/pacman.conf; then
            echo -e "\033[32mMultilib repository enabled successfully\033[0m"
        else
            echo -e "\033[31mFailed to enable multilib repository\033[0m"
            exit 1
        fi
    fi
    update_pkg_database
}

install_paru() {
    echo -e "\033[34m=== Installing paru AUR Helper ===\033[0m"
    echo "Installing paru for AUR package management..."
    # Check if paru is already installed
    if command -v paru &> /dev/null; then
        echo -e "\033[32mparu is already installed\033[0m"
    else
        # Install base-devel and git if not present
        echo "Installing prerequisites (base-devel, git)..."
        if sudo pacman -S --needed --noconfirm base-devel git; then
            echo -e "\033[32mPrerequisites installed successfully\033[0m"
        else
            echo -e "\033[31mFailed to install prerequisites\033[0m"
            exit 1
        fi
        # Clone paru repository
        echo "Cloning paru repository..."
        if git clone https://aur.archlinux.org/paru.git; then
            echo -e "\033[32mparu repository cloned successfully\033[0m"
        else
            echo -e "\033[31mFailed to clone paru repository\033[0m"
            exit 1
        fi
        # Build and install paru
        echo "Building and installing paru..."
        cd paru
        if makepkg -si --noconfirm; then
            echo -e "\033[32mparu installed successfully\033[0m"
        else
            echo -e "\033[31mFailed to build/install paru\033[0m"
            exit 1
        fi
        # Clean up
        cd ..
        rm -rf paru
        echo -e "\033[32mCleaned up temporary files\033[0m"
    fi
    echo ""
}

install_essentials() {
    echo -e "\033[34m=== Installing Essential Packages ===\033[0m"
    echo "Installing neovim, git, ssh, zsh, 7zip, C/C++ & Python libraries, fastfetch, wl-clipboard, fonts, fcitx5..."
    if paru -S --needed --noconfirm neovim git openssh zsh p7zip base-devel clang gdb cmake lldb valgrind python python-pip pyenv python-poetry fastfetch wl-clipboard nerd-fonts ttf-jetbrains-mono ttf-hack noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-ms-win11-auto fcitx5-im fcitx5-mozc fcitx5-rime; then
        echo -e "\033[32mEssential packages installed successfully\033[0m"
    else
        echo -e "\033[31mFailed to install essential packages\033[0m"
        exit 1
    fi
    echo ""
}

install_apps() {
    echo -e "\033[34m=== Installing Apps ===\033[0m"
    echo "Installing Notion, Spotify, Discord, WhatsApp, Floorp, LibreOffice, Okular, Gimp, feh, VLC, QBittorrent..."
    if paru -S --needed --noconfirm notion-app-electron spotify-launcher discord zapzap floorp-bin libreoffice-fresh okular gimp feh vlc qbittorrent; then
        echo -e "\033[32mApps installed successfully\033[0m"
    else
        echo -e "\033[31mFailed to install apps\033[0m"
        exit 1
    fi
    echo ""
}

install_games() {
    echo -e "\033[34m=== Installing Games ===\033[0m"
    echo "Installing Steam, PrismLauncher..."
    if paru -S --needed --noconfirm steam prismlauncher; then
        echo -e "\033[32mGames installed successfully\033[0m"
    else
        echo -e "\033[31mFailed to install games\033[0m"
        exit 1
    fi
    echo ""
}

kickstart_nvim() {
	echo -e "\033[34m=== Installing Kickstart Neovim ===\033[0m"
	local nvim_config_dir="$HOME/.config/nvim"
	local backup_dir="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
	echo "Installing Kickstart Neovim configuration..."
	# Check if Neovim is installed
	if ! command -v nvim &> /dev/null; then
		echo -e "\033[31mError: Neovim is not installed. Please install Neovim first.\033[0m"
		return 1
	fi
	# Backup existing Neovim configuration if it exists
	if [ -d "$nvim_config_dir" ]; then
		echo "Backing up existing Neovim config to: $backup_dir"
		mv "$nvim_config_dir" "$backup_dir"
	fi
	# Clone Kickstart Neovim
	echo "Cloning Kickstart Neovim configuration..."
	if git clone https://github.com/nvim-lua/kickstart.nvim.git "$nvim_config_dir"; then
		echo -e "\033[32mKickstart Neovim cloned successfully!\033[0m"
	else
		echo -e "\033[31mError: Failed to clone Kickstart Neovim repository\033[0m"
		# Restore backup if clone failed
		if [ -d "$backup_dir" ]; then
			echo "Restoring backup configuration..."
			mv "$backup_dir" "$nvim_config_dir"
		fi
		return 1
	fi
	# Remove .git directory to make it your own
	if [ -d "$nvim_config_dir/.git" ]; then
		echo "Removing .git directory to make it your own..."
		rm -rf "$nvim_config_dir/.git"
	fi
	echo -e "\033[32mKickstart Neovim installation complete!\033[0m"
	if [ -d "$backup_dir" ]; then
		echo "Previous config backed up to: $backup_dir"
	fi
	echo ""
}

setup_zsh() {
    echo -e "\033[34m=== Setting up ZSH with Oh-My-ZSH and Powerlevel10k ===\033[0m"
    
    # Install Oh-My-ZSH
    echo "Installing Oh-My-ZSH..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        if [ $? -eq 0 ]; then
            echo -e "\033[32mOh-My-ZSH installed successfully\033[0m"
        else
            echo -e "\033[31mFailed to install Oh-My-ZSH\033[0m"
            exit 1
        fi
    else
        echo -e "\033[32mOh-My-ZSH is already installed\033[0m"
    fi
    
    # Install Powerlevel10k theme
    echo "Installing Powerlevel10k theme..."
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
        if [ $? -eq 0 ]; then
            echo -e "\033[32mPowerlevel10k installed successfully\033[0m"
        else
            echo -e "\033[31mFailed to install Powerlevel10k\033[0m"
            exit 1
        fi
    else
        echo -e "\033[32mPowerlevel10k is already installed\033[0m"
    fi
    
    # Configure .zshrc
    echo "Configuring .zshrc..."
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "\033[32mBacked up existing .zshrc\033[0m"
    fi
    
    # Set Powerlevel10k as the theme
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    
    # Change default shell to zsh
    echo "Changing default shell to zsh..."
    if [ "$SHELL" != "/bin/zsh" ]; then
        chsh -s /bin/zsh
        echo -e "\033[32mDefault shell changed to zsh\033[0m"
    else
        echo -e "\033[32mZsh is already the default shell\033[0m"
    fi
    
    echo -e "\033[32mZSH setup completed!\033[0m"
    echo "Run 'p10k configure' after restarting your terminal to configure Powerlevel10k"
    echo ""
}

install_hyprland() {
    echo -e "\033[34m=== Installing Hyprland Desktop Environment ===\033[0m"
    echo "Installing Hyprland and related packages..."
    if paru -S --needed --noconfirm hyprland mako ghostty uwsm dolphin wofi xdg-desktop-portal-hyprland qt5-wayland qt6-wayland polkit-kde-agent grim slurp hyprpaper hyprpicker pipewire wireplumber waybar; then
        echo -e "\033[32mHyprland and related packages installed successfully\033[0m"
    else
        echo -e "\033[31mFailed to install Hyprland packages\033[0m"
        exit 1
    fi
    echo ""
}

# Main execution
echo "Starting Arch Linux installation setup..."
echo ""

#mount_drives
config_dns
enable_multilib
install_paru
install_essentials
install_apps
install_games
kickstart_nvim
setup_zsh
install_hyprland

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/restore.sh" ]; then
	source "$SCRIPT_DIR/restore.sh"
else
	echo -e "\033[31mWarning: restore.sh not found\033[0m"
fi

echo ""
echo -e "\033[34m=== Configuration Summary ===\033[0m"
echo "Desktop Environment: Hyprland"
echo "Shell: ZSH with Oh-My-ZSH and Powerlevel10k"
echo "AUR Helper: paru"
echo ""

echo -e "\033[32mInstallation completed successfully!\033[0m"
echo "Please reboot and run 'p10k configure' to set up Powerlevel10k theme"
