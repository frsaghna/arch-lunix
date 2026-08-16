#!/usr/bin/env bash
# Atomic reload hook triggered after wallpaper change

# 1. Reload Hyprland border colors
hyprctl reload >/dev/null 2>&1 || true

# 2. Reload Kitty terminals (SIGUSR1 reloads kitty.conf including colors.conf)
killall -SIGUSR1 kitty >/dev/null 2>&1 || true
kitty @ --to=unix:/tmp/kitty-socket set-colors -a /home/kimmi/.config/kitty/colors.conf >/dev/null 2>&1 || true

# 3. Synchronize Papirus folder icon colors to match wallpaper palette
/home/kimmi/.config/quickshell/scripts/sync-papirus-folders.py >/dev/null 2>&1 &
