#!/bin/bash

source "./colors.sh"

NVIM_CONFIG_DIR="$HOME/.config/nvim"
BCKP_DIR="../."
COMMON_BCKP_DIR="../../common/."

# Backup Neovim configuration
echo "{$BLUE}Backing up Neovim dotfiles...${RESET}"
if cp -r "$NVIM_CONFIG_DIR" "$COMMON_BCKP_DIR"; then
  echo "{$GREEN}Done!{$RESET}"
else
  echo "{$RED}Neovim dotfiles could not be backed up.{$RESET}"
  exit 1
fi
