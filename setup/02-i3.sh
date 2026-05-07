#!/usr/bin/env bash
# Install i3 and the helper apps the dotfiles config exec's, then link
# ~/dotfiles/.i3 into ~/.i3 (the legacy i3 config path used by this config).
# Idempotent.
#
# After running, log out and pick "i3" from the gear icon at the GDM login
# screen. i3 is X11-only, so this gives you an X session instead of Wayland.
set -euo pipefail

DOTFILES_I3="$HOME/dotfiles/.i3"
TARGET="$HOME/.i3"

PKGS=(
    i3                       # window manager (pulls in i3-wm, i3bar, i3-msg, i3-nagbar, i3-sensible-terminal)
    i3status                 # status line generator used by `bar { status_command i3status }`
    suckless-tools           # provides dmenu (Ubuntu 26.04 dropped the standalone `dmenu` package)
    pasystray                # tray volume icon, replaces volumeicon (gone from 26.04)
    network-manager-gnome    # provides nm-applet, exec'd at startup
    pulseaudio-utils         # provides pactl for the XF86Audio* keybinds
    xserver-xorg-input-libinput  # X11 input driver. Ubuntu 26.04 defaults to Wayland and doesn't pull this in for `apt install i3`. Without it, X starts and ignores every keyboard/mouse — symptom is "i3 looks frozen, mouse stuck, but the i3bar clock is still ticking".
    alacritty                # terminal bound to $mod+Return. Ubuntu 26.04's `x-terminal-emulator` alternative is ptyxis (GTK4/Wayland-only) and doesn't work in i3, so we bypass i3-sensible-terminal entirely.
)

missing=()
for pkg in "${PKGS[@]}"; do
    dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done

if (( ${#missing[@]} > 0 )); then
    echo "==> Installing: ${missing[*]}"
    sudo apt-get update
    sudo apt-get install -y "${missing[@]}"
else
    echo "==> i3 packages already installed"
fi

if [[ ! -d "$DOTFILES_I3" ]]; then
    echo "!! Missing $DOTFILES_I3 — run 00-bootstrap.sh first" >&2
    exit 1
fi

# Link ~/.i3 -> ~/dotfiles/.i3. If a real ~/.i3 already exists (not a symlink),
# move it aside so we don't clobber anything.
if [[ -L "$TARGET" ]]; then
    if [[ "$(readlink "$TARGET")" == "$DOTFILES_I3" ]]; then
        echo "==> $TARGET already linked"
    else
        echo "==> Re-pointing $TARGET to $DOTFILES_I3"
        ln -sfn "$DOTFILES_I3" "$TARGET"
    fi
elif [[ -e "$TARGET" ]]; then
    backup="$TARGET.bak.$(date +%s)"
    echo "==> Existing $TARGET found; moving to $backup"
    mv "$TARGET" "$backup"
    ln -s "$DOTFILES_I3" "$TARGET"
else
    echo "==> Linking $DOTFILES_I3 -> $TARGET"
    ln -s "$DOTFILES_I3" "$TARGET"
fi

echo
echo "Done. To start i3:"
echo "  1. Log out of GNOME."
echo "  2. At the GDM login screen, click your username, then the gear icon."
echo "  3. Select 'i3' and log in."
