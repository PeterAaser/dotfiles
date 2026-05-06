#!/usr/bin/env bash
# Install the NVIDIA proprietary driver for the Quadro P620 (Pascal/GP107GL)
# and pin apt against any 590+ branch package. Idempotent.
#
# Pascal is on the 580 Legacy branch; 590+ drivers print
# "The 5XX.XX.XX NVIDIA driver will ignore this GPU" on load and leave
# the system without a working GPU. Apt does not check hardware
# compatibility, so any `apt install nvidia-driver-595` or background
# unattended-upgrade can silently break the box. The pin file makes those
# metapackages uninstallable, so the failure mode becomes a refusal at
# install time instead of a black-screen-after-reboot.
set -euo pipefail

PIN=/etc/apt/preferences.d/nvidia-pin-580.pref

if [[ ! -f "$PIN" ]]; then
    echo "==> Writing $PIN"
    sudo tee "$PIN" >/dev/null <<'EOF'
# Block nvidia-driver-590+ on this box. The Quadro P620 (Pascal) is only
# supported by the 580 Legacy driver. Apt has no GPU-compat check, so
# without this an upgrade or accidental `apt install nvidia-driver-595`
# silently installs an incompatible driver and the GPU is unusable on
# the next reboot. Update this list every couple of years as new branches
# ship.
Package: nvidia-driver-590 nvidia-driver-595 nvidia-driver-600 nvidia-driver-605 nvidia-driver-610 nvidia-driver-615 nvidia-driver-620 nvidia-driver-625 nvidia-driver-630 nvidia-driver-635 nvidia-driver-640 nvidia-driver-645 nvidia-driver-650 nvidia-driver-655 nvidia-driver-660 nvidia-driver-665 nvidia-driver-670 nvidia-driver-675
Pin: release *
Pin-Priority: -1
EOF
else
    echo "==> $PIN already in place"
fi

if ! dpkg -s nvidia-driver-580 >/dev/null 2>&1; then
    echo "==> Installing nvidia-driver-580"
    sudo apt-get update
    sudo apt-get install -y nvidia-driver-580
else
    echo "==> nvidia-driver-580 already installed"
fi
