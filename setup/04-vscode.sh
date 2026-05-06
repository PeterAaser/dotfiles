#!/usr/bin/env bash
# Link VSCode user settings from dotfiles into VSCode's config location.
# Idempotent — safe to re-run.
#
# Note: this assumes VSCode is already installed via apt (`code` in PATH at
# /usr/bin/code). If you set up a fresh box, install VSCode first — the
# Microsoft apt repo is the cleanest way; the Ubuntu snap drops settings
# in a different path and would need ~/snap/code/current/.config/...
set -euo pipefail

SRC="$HOME/dotfiles/vscode_settings.json"
DEST_DIR="$HOME/.config/Code/User"
DEST="$DEST_DIR/settings.json"

if [[ ! -f "$SRC" ]]; then
    echo "!! Missing $SRC — run 00-bootstrap.sh first" >&2
    exit 1
fi

if ! command -v code >/dev/null; then
    echo "==> VSCode not installed; setting up Microsoft apt repo"
    KEYRING=/usr/share/keyrings/packages.microsoft.gpg
    if [[ ! -f "$KEYRING" ]]; then
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o "$KEYRING"
        sudo chmod go+r "$KEYRING"
    fi
    LIST=/etc/apt/sources.list.d/vscode.list
    if [[ ! -f "$LIST" ]]; then
        echo "deb [arch=amd64,arm64,armhf signed-by=$KEYRING] https://packages.microsoft.com/repos/code stable main" \
            | sudo tee "$LIST" >/dev/null
    fi
    sudo apt-get update
    sudo apt-get install -y code
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

# Force VSCode (Electron) onto the X11 ozone backend.
#
# On Ubuntu boxes where GDM reports XDG_SESSION_TYPE=wayland but the actual
# session is X11/i3 (no $WAYLAND_DISPLAY), Electron defaults to Wayland,
# fails to connect, and exits silently with no window and no error printed
# to the launching terminal. With --verbose you see:
#     Failed to connect to Wayland display: No such file or directory
#     Failed to initialize Wayland platform
# VSCode passes its own internal ozone hint that overrides
# $ELECTRON_OZONE_PLATFORM_HINT, so the env-var fix that works for other
# Electron apps does NOT work here — the flag has to be on argv.
#
# Two surfaces need it:
#  1. ~/.local/bin/code wrapper — covers terminal use (~/.local/bin is
#     ahead of /usr/bin in PATH on this setup, so this shadows the apt one).
#  2. ~/.local/share/applications/code.desktop — covers rofi/dmenu/i3
#     launcher entries, which read .desktop directly and don't go via PATH.

BIN_WRAPPER="$HOME/.local/bin/code"
mkdir -p "$(dirname "$BIN_WRAPPER")"
cat > "$BIN_WRAPPER" <<'EOF'
#!/bin/sh
# Force X11 ozone backend — see dotfiles/setup/04-vscode.sh for the why.
exec /usr/bin/code --ozone-platform=x11 "$@"
EOF
chmod +x "$BIN_WRAPPER"
echo "==> Installed $BIN_WRAPPER"

SYS_DESKTOP="/usr/share/applications/code.desktop"
USER_DESKTOP="$HOME/.local/share/applications/code.desktop"
if [[ -f "$SYS_DESKTOP" ]]; then
    mkdir -p "$(dirname "$USER_DESKTOP")"
    sed 's|Exec=/usr/share/code/code |Exec=/usr/share/code/code --ozone-platform=x11 |g' \
        "$SYS_DESKTOP" > "$USER_DESKTOP"
    echo "==> Wrote $USER_DESKTOP with --ozone-platform=x11"
else
    echo "!! $SYS_DESKTOP not found; skipping launcher override"
fi
