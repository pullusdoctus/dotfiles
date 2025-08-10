#!/bin/bash

source "./colors.sh"

NVIM_CONFIG_DIR="$HOME/.config/nvim"

BCKP_DIR="../dotfiles/"
NVIM_BCKP_DIR="$BCKP_DIR/nvim"

echo -e "${BLUE}Backing up Neovim dotfiles...${RESET}"
if [ -d $NVIM_BCKP_DIR ]; then
  rm -rf "$NVIM_BCKP_DIR"
fi
if cp -r "$NVIM_CONFIG_DIR" "$BCKP_DIR"; then
  echo -e "${GREEN}Done!${RESET}"
else
  echo -e "${RED}Neovim dotfiles could not be backed up.${RESET}"
  exit 1
fi
