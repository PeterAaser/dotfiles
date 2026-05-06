#!/usr/bin/env bash
# Enable full Magic SysRq so the kernel can do safe-reboot (REISUB) when
# userspace is wedged. Default Ubuntu has SysRq partially disabled, which
# means the recovery sequence fails on the disabled operations. Setting to
# 1 enables all operations.
#
# Idempotent.
set -euo pipefail

CONF=/etc/sysctl.d/99-sysrq.conf

if [[ -f "$CONF" ]] && grep -q '^kernel.sysrq=1' "$CONF"; then
    echo "==> $CONF already sets kernel.sysrq=1"
else
    echo "==> Writing $CONF"
    echo 'kernel.sysrq=1' | sudo tee "$CONF" >/dev/null
fi

current=$(cat /proc/sys/kernel/sysrq)
if [[ "$current" != "1" ]]; then
    echo "==> Applying live (was $current)"
    echo 1 | sudo tee /proc/sys/kernel/sysrq >/dev/null
fi

echo "Done. kernel.sysrq=$(cat /proc/sys/kernel/sysrq)"
