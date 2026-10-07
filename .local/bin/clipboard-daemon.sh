#!/usr/bin/env bash
# Clipboard daemon managing history and watchers.
# Part of Omarchy Global Clipboard System
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/clipboard"
HISTORY_FILE="$STATE_DIR/history.json"
CAPTURE_SCRIPT="$(dirname "$(realpath "$0")")/capture.sh"
mkdir -p "$STATE_DIR"
[[ -f "$HISTORY_FILE" ]] || echo "[]" > "$HISTORY_FILE"

append_entry() {
  local json="$1"
  [[ -n "$json" ]] || return 0

  # Append new entry to the front, deduplicate, limit to 500 items
  (
    flock -x 200
    local tmp_file
    tmp_file=$(mktemp "$STATE_DIR/history.XXXXXX")
    jq --argjson new "$json" '
      [$new] + map(select(
        if $new.type == "image" then .path != $new.path
        else .text != $new.text end
      )) | .[0:500]
    ' "$HISTORY_FILE" > "$tmp_file" && mv "$tmp_file" "$HISTORY_FILE"
  ) 200>"$STATE_DIR/.history.lock"
}

cleanup() {
  jobs -p | xargs -r kill 2>/dev/null || true
  exit 0
}
trap cleanup SIGINT SIGTERM SIGHUP

# Watchers using pipes with setpriv --pdeathsig TERM
setpriv --pdeathsig TERM wl-paste --type text --watch "$CAPTURE_SCRIPT" text 2>/dev/null | while read -r line; do
  append_entry "$line"
done &

setpriv --pdeathsig TERM wl-paste --type image/png --watch "$CAPTURE_SCRIPT" image/png 2>/dev/null | while read -r line; do
  append_entry "$line"
done &

wait
