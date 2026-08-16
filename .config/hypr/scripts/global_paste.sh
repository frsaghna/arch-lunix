#!/usr/bin/env bash

# Universal Global Paste Helper
active_class=$(hyprctl activewindow 2>/dev/null | awk -F': ' '/class:/ {print $2}')

case "$active_class" in
    kitty|Alacritty|foot|org.wezfurlong.wezterm|xterm*|gnome-terminal*|konsole)
        if command -v wtype >/dev/null 2>&1; then
            wtype -M ctrl -M shift -k v -m shift -m ctrl
        else
            hyprctl dispatch sendshortcut "CTRL SHIFT,v,activewindow" >/dev/null 2>&1
        fi
        ;;
    *)
        if command -v wtype >/dev/null 2>&1; then
            wtype -M ctrl -k v -m ctrl
        else
            hyprctl dispatch sendshortcut "CTRL,v,activewindow" >/dev/null 2>&1
        fi
        ;;
esac
