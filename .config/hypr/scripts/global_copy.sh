#!/usr/bin/env bash

# Universal Global Copy Helper
active_class=$(hyprctl activewindow 2>/dev/null | awk -F': ' '/class:/ {print $2}')

case "$active_class" in
    kitty|Alacritty|foot|org.wezfurlong.wezterm|xterm*|gnome-terminal*|konsole)
        if command -v wtype >/dev/null 2>&1; then
            wtype -M ctrl -M shift -k c -m shift -m ctrl
        else
            hyprctl dispatch sendshortcut "CTRL SHIFT,c,activewindow" >/dev/null 2>&1
        fi
        ;;
    *)
        if command -v wtype >/dev/null 2>&1; then
            wtype -M ctrl -k c -m ctrl
        else
            hyprctl dispatch sendshortcut "CTRL,c,activewindow" >/dev/null 2>&1
        fi
        ;;
esac
