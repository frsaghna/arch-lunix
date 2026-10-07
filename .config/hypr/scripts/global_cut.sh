#!/usr/bin/env bash
# Universal Global Cut Helper
# Part of Omarchy Global Clipboard System
set -euo pipefail

hyprctl dispatch "hl.dsp.send_shortcut({ mods = 'CTRL', key = 'x' })" >/dev/null 2>&1 || wtype -M ctrl -k x -m ctrl
