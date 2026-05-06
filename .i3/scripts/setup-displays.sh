#!/usr/bin/env sh
# Disable all connected monitors except the primary one. Runs inside the
# i3 X11 session, where xrandr actually owns the output configuration
# (unlike under Wayland/Xwayland, where xrandr can read but not modify).
#
# Picks "primary" if xrandr marks one; otherwise falls back to the first
# connected output. Logs before+after state to ~/i3-debug/displays.log so
# we can verify what happened even if i3 freezes later.
set -eu

mkdir -p "$HOME/i3-debug"
log="$HOME/i3-debug/displays.log"

{
    echo "=== $(date) before ==="
    xrandr --query
} > "$log" 2>&1

primary=$(xrandr --query | awk '$2=="connected" && /primary/ {print $1; exit}')
if [ -z "$primary" ]; then
    primary=$(xrandr --query | awk '$2=="connected" {print $1; exit}')
fi
echo "primary: $primary" >> "$log"

xrandr --query | awk '$2=="connected" {print $1}' | while read -r out; do
    if [ "$out" != "$primary" ]; then
        echo "disabling: $out" >> "$log"
        xrandr --output "$out" --off >> "$log" 2>&1 || echo "  (failed)" >> "$log"
    fi
done

{
    echo "=== after ==="
    xrandr --query
} >> "$log" 2>&1
