#!/usr/bin/env bash
# Install custom XKB layout by COPYING ~/dotfiles/{us,pc} into the system
# xkb symbols dir. Idempotent — copies only when content differs.
#
# Why copies and not symlinks: GDM's greeter runs as user `gdm-greeter`,
# which cannot traverse /home/peter (mode 750). A symlink from
# /usr/share/X11/xkb/symbols/pc into /home/peter/dotfiles/pc resolves
# to permission-denied for that user, libxkbcommon fails to compile the
# keymap, and gnome-shell core-dumps on the greeter — black screen at
# login. Copies live in /usr/share where any user can read them.
#
# After running, log out and back in (or `sudo systemctl restart gdm`) so
# the greeter reloads the symbols. A gsettings toggle is attempted as a
# best-effort live reload for the current GNOME/Wayland session.
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
XKB_DIR="/usr/share/X11/xkb/symbols"
FILES=(us pc)

for f in "${FILES[@]}"; do
    src="$DOTFILES_DIR/$f"
    dst="$XKB_DIR/$f"
    backup="$dst.orig"

    if [[ ! -f "$src" ]]; then
        echo "!! Missing source: $src — run 00-bootstrap.sh first" >&2
        exit 1
    fi

    # Back up the system original exactly once. Skip if a symlink is already
    # in place (left over from earlier symlink-based installs) — the .orig
    # already exists in that case.
    if [[ ! -e "$backup" && ! -L "$dst" ]]; then
        echo "==> Backing up $dst -> $backup"
        sudo cp -a "$dst" "$backup"
    fi

    # Replace any existing symlink first (cp -f won't follow into a symlink
    # outside its target's perms, and we want a real file at $dst regardless).
    if [[ -L "$dst" ]]; then
        echo "==> Removing stale symlink at $dst"
        sudo rm -f "$dst"
    fi

    if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
        echo "==> $dst already up to date"
    else
        echo "==> Copying $src -> $dst"
        sudo install -m 0644 "$src" "$dst"
    fi
done

# Clear libxkbcommon's compiled cache so Wayland clients pick up the new symbols.
rm -rf "$HOME/.cache/xkbcommon" 2>/dev/null || true

# Best-effort live reload: toggle gsettings to force GNOME to recompile.
if command -v gsettings >/dev/null && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    current=$(gsettings get org.gnome.desktop.input-sources sources 2>/dev/null || echo "")
    if [[ -n "$current" ]]; then
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'gb')]" || true
        sleep 0.2
        gsettings set org.gnome.desktop.input-sources sources "$current" || true
    fi
fi

echo
echo "Done. If the greeter is broken or you just changed the layout, run:"
echo "  sudo systemctl restart gdm"
