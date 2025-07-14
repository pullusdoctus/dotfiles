#!/bin/bash

NVIM_BCKP_DIR="../../common/nvim"
CONFIG_DIR="$HOME/.config/."

# Restore Neovim dotfiles
echo "{$BLUE}Restoring Neovim configuration...{$RESET}"
if cp -r "$NVIM_BCKP_DIR" "$CONFIG_DIR"; then
  echo "{$GREEN}Done!{$RESET}"
else
  echo "{$RED}Could not restore Neovim configuration{$RESET}"
  exit 1
fi
