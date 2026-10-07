#!/usr/bin/env bash
# Universal Global Copy Helper
# Part of Omarchy Global Clipboard System
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

is_terminal() {
    hyprctl activewindow -j 2>/dev/null | jq -e '.class | test("(?i)kitty|alacritty|ghostty|foot|wezterm|xterm|gnome-terminal|konsole")' >/dev/null 2>&1
}

if is_terminal; then
    hyprctl dispatch "hl.dsp.send_shortcut({ mods = 'CTRL SHIFT', key = 'c' })" >/dev/null 2>&1 || wtype -M ctrl -M shift -k c -m shift -m ctrl
else
    hyprctl dispatch "hl.dsp.send_shortcut({ mods = 'CTRL', key = 'c' })" >/dev/null 2>&1 || wtype -M ctrl -k c -m ctrl
fi
