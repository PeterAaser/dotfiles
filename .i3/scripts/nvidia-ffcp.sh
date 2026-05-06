#!/usr/bin/env sh
# Enable ForceFullCompositionPipeline on the primary NVIDIA output. This
# moves all compositing inside the NVIDIA driver, which is the standard
# mitigation when X11 + i3 + NVIDIA proprietary "Implicit sync not fully
# supported" causes silent GPU hangs (driver stops drawing, mouse freezes,
# only SysRq escapes — symptom this script aims to prevent).
#
# Runs after setup-displays.sh — relies on a single primary output existing.
# Logs to ~/i3-debug/nvidia-ffcp.log.
set -eu

mkdir -p "$HOME/i3-debug"
log="$HOME/i3-debug/nvidia-ffcp.log"

primary=$(xrandr --query | awk '$2=="connected" && /primary/ {print $1; exit}')
if [ -z "$primary" ]; then
    primary=$(xrandr --query | awk '$2=="connected" {print $1; exit}')
fi

mode="$primary: nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
{
    echo "=== $(date) ==="
    echo "primary: $primary"
    echo "applying: $mode"
    nvidia-settings --assign "CurrentMetaMode=$mode" 2>&1 || echo "  FAILED ($?)"
} > "$log"
