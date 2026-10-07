#!/usr/bin/env bash
# Captures current Wayland clipboard entry to JSON.
# Part of Omarchy Global Clipboard System
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/clipboard"
IMAGE_DIR="$STATE_DIR/images"
mkdir -p "$IMAGE_DIR"

types=$(wl-paste --list-types 2>/dev/null || true)

# Ignore sensitive/password manager clips
if [[ ${CLIPBOARD_STATE:-} == "sensitive" ]] || grep -qx 'x-kde-passwordManagerHint' <<<"$types"; then
  exit 0
fi

emit_image() {
  local mime="$1" ext tmp hash file
  ext=${mime#image/}
  [[ $ext == jpeg ]] && ext=jpg

  tmp=$(mktemp --tmpdir="$IMAGE_DIR" clip.XXXXXX) || return 0
  cat >"$tmp"
  if [[ ! -s $tmp ]]; then
    rm -f "$tmp"
    return 0
  fi

  hash=$(sha256sum "$tmp" | awk '{print $1}')
  file="$IMAGE_DIR/$hash.$ext"
  if [[ -e $file ]]; then
    rm -f "$tmp"
  else
    mv "$tmp" "$file"
  fi

  jq -cn --arg mime "$mime" --arg path "$file" --arg captured_at "$(date +'%A %H:%M')" \
    '{type:"image", mime:$mime, path:$path, capturedAt:$captured_at}'
}

emit_text() {
  perl -MEncode=decode,FB_CROAK,LEAVE_SRC -MJSON::PP=encode_json -0777 -e '
    my $raw = <STDIN>;
    exit unless length $raw;
    my $encoding;
    if ($raw =~ /^(?:\xFF\xFE|\xFE\xFF)/) {
      $encoding = "UTF-16";
    } elsif (length($raw) >= 4) {
      my @bytes = unpack("C*", $raw);
      my ($even_nulls, $odd_nulls) = (0, 0);
      for (my $i = 0; $i < @bytes; $i++) {
        if ($bytes[$i] == 0) {
          if ($i % 2 == 0) { $even_nulls++; } else { $odd_nulls++; }
        }
      }
      my $pairs = int(@bytes / 2);
      if ($odd_nulls > $pairs * 0.4 && $even_nulls == 0) {
        $encoding = "UTF-16LE";
      } elsif ($even_nulls > $pairs * 0.4 && $odd_nulls == 0) {
        $encoding = "UTF-16BE";
      }
    }
    my $text = $encoding ? eval { decode($encoding, $raw, FB_CROAK | LEAVE_SRC) } : undef;
    $text = decode("UTF-8", $raw) unless defined $text;
    exit unless length $text;
    print "{\"type\":\"text\",\"text\":", encode_json($text), "}\n";
  '
}

case "${1:-}" in
  text) emit_text; exit 0 ;;
  image/*) emit_image "$1"; exit 0 ;;
esac
