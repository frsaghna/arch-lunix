#!/usr/bin/env python3
import json
import colorsys
import subprocess
import os

colors_file = os.path.expanduser("~/.cache/matugen/colors.json")
if not os.path.exists(colors_file):
    exit(0)

try:
    with open(colors_file, "r") as f:
        data = json.load(f)
    
    hex_color = data.get("primary", "#5E81AC").lstrip("#")
    r, g, b = tuple(int(hex_color[i:i+2], 16) / 255.0 for i in (0, 2, 4))
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    hue = h * 360

    if s < 0.18:
        folder_color = "grey" if v > 0.4 else "black"
    elif hue < 15 or hue >= 345:
        folder_color = "red"
    elif 15 <= hue < 40:
        folder_color = "orange"
    elif 40 <= hue < 70:
        folder_color = "yellow"
    elif 70 <= hue < 160:
        folder_color = "green"
    elif 160 <= hue < 195:
        folder_color = "cyan"
    elif 195 <= hue < 235:
        folder_color = "nordic"
    elif 235 <= hue < 280:
        folder_color = "violet"
    elif 280 <= hue < 320:
        folder_color = "magenta"
    else:
        folder_color = "pink"

    script = os.path.expanduser("~/.local/bin/papirus-folders")
    if os.path.exists(script):
        subprocess.run([script, "-C", folder_color, "-t", "Papirus-Dark"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        # Update icon cache
        subprocess.run(["gtk-update-icon-cache", "-q", "-t", "-f", os.path.expanduser("~/.local/share/icons/Papirus-Dark")], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
except Exception:
    pass
