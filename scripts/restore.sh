#!/bin/bash

NVIM_BCKP_DIR="../../common/nvim"
CONFIG_DIR="$HOME/.config/."

echo -e "${BLUE}Restoring Neovim configuration...${RESET}"
if cp -r "$NVIM_BCKP_DIR" "$CONFIG_DIR"; then
  echo -e "${GREEN}Done!${RESET}"
else
  echo -e "${RED}Could not restore Neovim configuration${RESET}"
  exit 1
fi
