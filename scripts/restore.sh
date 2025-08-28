#!/bin/bash

source "./colors.sh"
source "./vars.sh"

while true; do
  read -rp "Do you want to generate new SSH keys? (y/n): " ANSWER
  ANSWER=$(echo "$ANSWER" | tr '[:upper]' '[:lower]')
  if [[ "$ANSWER" == "y" || "$ANSWER" == "yes" ]]; then
    echo -e "${BLUE}Generating new SSH keys...${RESET}"
    read -rp "Email to use: " SSH_EMAIL
    read -rp "Name for SSH key file: " SSH_FILE
    mkdir -p "$SSH_DIR"
    if ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_DIR/$SSH_FILE" -N ""; then
      echo -e "${GREEN}New SSH keys generated succesfully.${RESET}"
      chmod 700 "$SSH_DIR"
      chmod 600 "$SSH_DIR/$SSH_FILE"
      chmod 644 "$SSH_DIR/$SSH_FILE.pub"
      echo -e "${MAGENTA}Your public key:${RESET}"
      cat "$SSH_DIR/$SSH_FILE.pub"
    else
      echo -e "${RED}Failed to generate new SSH keys.${RESET}"
      exit 1
    fi
    break
  elif [[ "$ANSWER" == "n" || "$ANSWER" == "no" ]]; then
    echo "No SSH keys will be installed."
    echo ""
    break
  else
    echo "Make sure to answer with a valid input (y/n or yes/no)"
  fi
done

echo -e "${BLUE}Restoring OpenVPN configuration...${RESET}"
if [ -d $VPN_BCKP_DIR ]; then
  if [ -d $VPN_DIR ]; then
    rm -rf "$VPN_DIR"
  fi
  if cp -r "$VPN_BCKP_DIR" "$VPN_DIR"; then
    echo -e "${GREEN}Done!${RESET}"
  else
    echo -e "${RED}OpenVPN could not be restored.${RESET}"
    exit 1
  fi
else
  echo -e "${YELLOW}No OpenVPN backup found.${RESET}"
fi

echo -e "${BLUE}Restoring SSH configuration...${RESET}"
if [ -d "$SSH_BCKP_DIR" ] && [ -f "$SSH_BCKP_DIR/config" ]; then
  mkdir -p "$SSH_DIR"
  if cp "$SSH_BCKP_DIR/config" "$SSH_DIR/config"; then
    chmod 600 "$SSH_DIR/config"
    echo -e "${GREEN}Done!${RESET}"
  else
    echo -e "${RED}Could not restore SSH configuration.${RESET}"
    exit 1
  fi
else
  echo -e "${YELLOW}No SSH configuration backup found.${RESET}"
fi

echo -e "${BLUE}Restoring Git configuration...${RESET}"
if [ -d "$GIT_BCKP_DIR" ] && [ -f "$GIT_BCKP_DIR/.gitconfig" ]; then
  if cp "$GIT_BCKP_DIR/.gitconfig" "$HOME/"; then
    echo -e "${GREEN}Done!${RESET}"
  else
    echo -e "${RED}Could not restore Git configuration.${RESET}"
    exit 1
  fi
else
  echo -e "${YELLOW}No Git configuration backup found.${RESET}"
fi

echo -e "${BLUE}Restoring Neovim configuration...${RESET}"
if [ -d "$NVIM_BCKP_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
  if [ -d "$NVIM_DIR" ]; then
    rm -rf "$NVIM_DIR"
  fi
  if cp -r "$NVIM_BCKP_DIR" "$NVIM_DIR"; then
    echo -e "${GREEN}Done!${RESET}"
  else
    echo -e "${RED}Could not restore Neovim configuration.${RESET}"
    exit 1
  fi
else
  echo -e "${YELLOW}No Neovim configuration backup found.${RESET}"
fi

echo -e "${BLUE}Restoring wallpapers...${RESET}"
if [ -d "$WP_BCKP_DIR" ]; then
  mkdir -p "$DATA_DIR"
  mkdir -p "$IMG_DIR"
  if [ -d "$WP_DIR" ]; then
    rm -rf "$WP_DIR"
  fi
  if cp -r "$WP_BCKP_DIR" "$WP_DIR"; then
    echo -e "${GREEN}Done!${RESET}"
  else
    echo -e "${RED}Could not restore wallpapers.${RESET}$"
    exit 1
  fi
else
  echo -e "${YELLOW}No wallpapers backup found.${RESET}"
fi

echo -e "${BLUE}Restoring Kitty config...${RESET}"
if [ -d "$KITTY_BCKP_DIR" ]; then
  if [ -d "$KITTY_DIR" ]; then
    rm -rf "$KITTY_DIR"
  fi
  if cp -r "$KITTY_BCKP_DIR" "$KITTY_DIR"; then
    echo -e "${GREEN}Done!${RESET}"
  else
    echo -e "${RED}Could not restore Kitty config.${RESET}"
    exit 1
  fi
else
  echo -e "${YELLOW}No Kitty backup found.${RESET}"
fi

echo -e "${BLUE}Restoring Fastfetch config...${RESET}"
if [ -d "$FF_BCKP_DIR" ]; then
  if [ -d "$FF_DIR" ]; then
    rm -rf "$FF_DIR"
  fi
  if cp -r "$FF_BCKP_DIR" "$FF_DIR"; then
    echo -e "${GREEN}Done!${RESET}"
  else
    echo -e "${RED}Could not restore Fastfetch config.${RESET}"
    exit 1
  fi
else
  echo -e "${YELLOW}No Fastfetch backup found.${RESET}"
fi

restore_waybar() {
  echo -e "${BLUE}Restoring Waybar config...${RESET}"
  if [ -d "$WAYBAR_BCKP_DIR" ]; then
    if [ -d "$WAYBAR_DIR" ]; then
      rm -rf "$WAYBAR_DIR"
    fi
    if cp -r "$WAYBAR_BCKP_DIR" "$WAYBAR_DIR"; then
      echo -e "${GREEN}Done!${RESET}"
    else
      echo -e "${RED}Could not restore Waybar config.${RESET}"
      exit 1
    fi
  else
    echo -e "${YELLOW}No Waybar backup found.${RESET}"
  fi
}

restore_sway() {
  echo -e "${BLUE}Restoring SwayWM config...${RESET}"
  if [ -d "$SWAY_BCKP_DIR" ]; then
    if [ -d "$SWAY_DIR" ]; then
      rm -rf "$SWAY_DIR"
    fi
    if cp -r "$SWAY_BCKP_DIR" "$SWAY_DIR"; then
      echo -e "${GREEN}Done!${RESET}"
    else
      echo -e "${RED}Could not restore SwayWM config.${RESET}"
      exit 1
    fi
    restore_waybar
  else
    echo -e "${YELLOW}No SwayWM backup found.${RESET}"
  fi
}

echo -e "${BLUE}Restoring DE/WM config...${RESET}"
WM=$(fastfetch | grep -i "WM:" | awk '{print $2}')
case $WM in
  Sway)
    restore_sway
    ;;
  # TODO: Hyprland
  # TODO: KDE Plasma
  *)
    echo -e "${YELLOW}Unknown DE/WM detected: $WM${RESET}"
    ;;
esac
echo -e "${GREEN}Restoration finished!${RESET}"
echo -e "${BOLD}Please reboot your system to avoid issues.${RESET}"
