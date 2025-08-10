#!/bin/bash
# arch_maintenance.sh - Automatic system maintenance script

# update packages
paru -Syu | tee /tmp/paru_syu_out.txt
if grep -q "marginal trust" /tmp/paru_syu_out.txt; then
  paru -Sy --needed archlinux-keyring
fi
rm -f /tmp/paru_syu_out.txt

# clean pacman cache
sudo ls /var/cache/pacman/pkg/ | wc -l  # cached packages
du -sh /var/cache/pacman/pkg/           # space used
paru -Sy --needed pacman-contrib
sudo paccache -r

# remove orphan packages
paru -Qdtq | paru -Rns - 2>/dev/null

# clean home cache
rm -rf ~/.cache/

# system logs clean-up
sudo journalctl --vacuum-time=7d
