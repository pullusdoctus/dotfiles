#!/bin/bash
# 2025/03/31
# arch_maintenance.sh - Automatic system maintenance script

# update packages
yay -Syu | tee /tmp/yay_syu_out.txt
if grep -q "marginal trust" /tmp/yay_syu_out.txt; then
	yay -Sy --needed archlinux-keyring
fi
rm -f /tmp/yay_syu_out.txt

# clean pacman cache
sudo ls /var/cache/pacman/pkg/ | wc -l  # cached packages
du -sh /var/cache/pacman/pkg/ 					# space used
yay -Sy --needed pacman-contrib
sudo paccache -r

# remove orphan packages
yay -Qdtq | yay -Rns - 2>/dev/null

# clean home cache
rm -rf ~/.cache/

# system logs clean-up
sudo journalctl --vacuum-time=7d
