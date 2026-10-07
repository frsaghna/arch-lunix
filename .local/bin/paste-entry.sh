#!/usr/bin/env bash
# Pastes or copies selected history entry.
# Usage: paste-entry.sh [--copy-only | --delete | --clear] [history-index]
# Part of Omarchy Global Clipboard System
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/clipboard"
HISTORY_FILE="$STATE_DIR/history.json"
mkdir -p "$STATE_DIR"
[[ -f "$HISTORY_FILE" ]] || echo "[]" > "$HISTORY_FILE"

ACTION="paste"
if [[ "${1:-}" == "--copy-only" ]]; then
  ACTION="copy"
  shift
elif [[ "${1:-}" == "--delete" ]]; then
  ACTION="delete"
  shift
elif [[ "${1:-}" == "--clear" ]]; then
  ACTION="clear"
  shift
fi

if [[ "$ACTION" == "clear" ]]; then
  (
    flock -x 200
    echo "[]" > "$HISTORY_FILE"
  ) 200>"$STATE_DIR/.history.lock"
  exit 0
fi

INDEX="${1:-0}"

if [[ "$ACTION" == "delete" ]]; then
  (
    flock -x 200
    tmp_file=$(mktemp "$STATE_DIR/history.XXXXXX")
    jq --argjson i "$INDEX" 'del(.[$i])' "$HISTORY_FILE" > "$tmp_file" && mv "$tmp_file" "$HISTORY_FILE"
  ) 200>"$STATE_DIR/.history.lock"
  exit 0
fi

type=$(jq -r --argjson i "$INDEX" '.[$i].type // empty' "$HISTORY_FILE")
[[ -n "$type" ]] || exit 1

if [[ "$type" == "image" ]]; then
  mime=$(jq -r --argjson i "$INDEX" '.[$i].mime' "$HISTORY_FILE")
  path=$(jq -r --argjson i "$INDEX" '.[$i].path' "$HISTORY_FILE")
  wl-copy --type "$mime" < "$path"
else
  jq -j --argjson i "$INDEX" '.[$i].text' "$HISTORY_FILE" | wl-copy
fi

if [[ "$ACTION" == "paste" ]]; then
  sleep 0.15
  hyprctl dispatch "hl.dsp.send_shortcut({ mods = 'SHIFT', key = 'Insert' })" >/dev/null 2>&1 || wtype -M shift -k Insert -m shift 2>/dev/null || true
fi
