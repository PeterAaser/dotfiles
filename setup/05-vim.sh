#!/usr/bin/env bash
# Link the .vimrc from dotfiles into ~/.vimrc. Idempotent.
set -euo pipefail

SRC="$HOME/dotfiles/.vimrc"
DEST="$HOME/.vimrc"

if [[ ! -f "$SRC" ]]; then
    echo "!! Missing $SRC — run 00-bootstrap.sh first" >&2
    exit 1
fi

if [[ -L "$DEST" && "$(readlink "$DEST")" == "$SRC" ]]; then
    echo "==> $DEST already linked"
elif [[ -e "$DEST" && ! -L "$DEST" ]]; then
    backup="$DEST.bak.$(date +%s)"
    echo "==> Existing $DEST found; moving to $backup"
    mv "$DEST" "$backup"
    ln -s "$SRC" "$DEST"
else
    echo "==> Linking $SRC -> $DEST"
    ln -sfn "$SRC" "$DEST"
fi
