#!/usr/bin/env bash
# Install alacritty (if missing) and link the dotfiles config into
# ~/.config/alacritty/alacritty.toml. Idempotent — safe to re-run.
set -euo pipefail

SRC="$HOME/dotfiles/alacritty.toml"
DEST_DIR="$HOME/.config/alacritty"
DEST="$DEST_DIR/alacritty.toml"

if [[ ! -f "$SRC" ]]; then
    echo "!! Missing $SRC — run 00-bootstrap.sh first" >&2
    exit 1
fi

if ! command -v alacritty >/dev/null; then
    echo "==> Installing alacritty"
    sudo apt-get update
    sudo apt-get install -y alacritty
else
    echo "==> alacritty already installed"
fi

mkdir -p "$DEST_DIR"

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
