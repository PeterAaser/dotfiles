#!/usr/bin/env bash
# Bootstrap a fresh Ubuntu install: base packages + dotfiles clone.
# Idempotent — safe to re-run.
set -euo pipefail

DOTFILES_REPO="https://github.com/PeterAaser/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

BASE_PKGS=(git curl)

missing=()
for pkg in "${BASE_PKGS[@]}"; do
    dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done

if (( ${#missing[@]} > 0 )); then
    echo "==> Installing: ${missing[*]}"
    sudo apt-get update
    sudo apt-get install -y "${missing[@]}"
else
    echo "==> Base packages already installed"
fi

if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
    echo "==> Cloning dotfiles to $DOTFILES_DIR"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo "==> Dotfiles already cloned at $DOTFILES_DIR"
fi
