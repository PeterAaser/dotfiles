#!/usr/bin/env bash
# Append bashrc_extra to ~/.bashrc if it isn't already there. Idempotent.
# Uses the marker line "# peter config begin:" as the presence check, so
# re-runs are safe even if ~/.bashrc has been edited around it.
set -euo pipefail

SRC="$HOME/dotfiles/bashrc_extra"
DEST="$HOME/.bashrc"
MARKER="# peter config begin:"

if [[ ! -f "$SRC" ]]; then
    echo "!! Missing $SRC — run 00-bootstrap.sh first" >&2
    exit 1
fi

if [[ ! -f "$DEST" ]]; then
    echo "!! $DEST does not exist — Ubuntu's default skeleton should provide it" >&2
    exit 1
fi

if grep -qF "$MARKER" "$DEST"; then
    echo "==> $DEST already contains '$MARKER' — skipping append"
else
    # Ensure a separating newline before the appended block.
    [[ -s "$DEST" && -z "$(tail -c1 "$DEST")" ]] || printf '\n' >> "$DEST"
    cat "$SRC" >> "$DEST"
    echo "==> Appended $SRC to $DEST"
fi
