#!/usr/bin/env bash
# clipboard-menu.sh: Wayland Clipboard History Picker
# Part of Omarchy Global Clipboard System
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/clipboard"
HISTORY_FILE="$STATE_DIR/history.json"
[[ -f "$HISTORY_FILE" ]] || exit 0

# Format entries with indices
ENTRIES=$(jq -r 'to_entries[] | "\(.key): \(.value.type == "image" ? "[Image] " + .value.path : (.value.text | gsub("\n"; " ") | .[0:100]))"' "$HISTORY_FILE" 2>/dev/null || true)

[[ -n "$ENTRIES" ]] || exit 0

CHOSEN=""
if command -v wofi >/dev/null 2>&1; then
  CHOSEN=$(printf '%s\n' "$ENTRIES" | wofi --dmenu --prompt "Clipboard" --insensitive --width 800 --height 450 || true)
elif command -v rofi >/dev/null 2>&1; then
  CHOSEN=$(printf '%s\n' "$ENTRIES" | rofi -dmenu -i -p "Clipboard" || true)
elif command -v fuzzel >/dev/null 2>&1; then
  CHOSEN=$(printf '%s\n' "$ENTRIES" | fuzzel --dmenu --prompt "Clipboard: " --width 80 || true)
fi

[[ -n "$CHOSEN" ]] || exit 0

INDEX="${CHOSEN%%:*}"
"$(dirname "$(realpath "$0")")/paste-entry.sh" "$INDEX"
