#!/bin/bash

source "./colors.sh"

CONFIG_DIR="$HOME/.config"
SSH_DIR="$HOME/.ssh"
NVIM_DIR="$CONFIG_DIR/nvim"
DATA_DIR="$HOME/data"
IMG_DIR="$DATA_DIR/img"
WP_DIR="$IMG_DIR/wp"

COMMON_BCKP_DIR="./common"
SSH_BCKP_DIR="$COMMON_BCKP_DIR/ssh"
GIT_BCKP_DIR="$COMMON_BCKP_DIR/git"
NVIM_BCKP_DIR="$COMMON_BCKP_DIR/nvim"
WP_BCKP_DIR="$COMMON_BCKP_DIR/wp"

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

echo -e "${GREEN}Restoration finished!${RESET}"
echo -e "${BOLD}Please reboot your system to avoid issues.${RESET}"
