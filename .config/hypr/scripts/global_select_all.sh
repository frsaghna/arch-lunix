#!/usr/bin/env bash
# Universal Global Select All Helper
# Part of Omarchy Global Clipboard System
set -euo pipefail

hyprctl dispatch "hl.dsp.send_shortcut({ mods = 'CTRL', key = 'a' })" >/dev/null 2>&1 || wtype -M ctrl -k a -m ctrl
