#!/bin/bash

sudo apt update
sudo apt install -y gnupg-agent gpg-agent pinentry-curses

# Device
export FOX_BRANCH="fox_12.1"
export DT_LINK="https://ImSpiDy:$my_og_token@github.com/ImSpiDy/device_xiaomi_lavender_recovery -b rdp"

export DEVICE="lavender"
export OEM="xiaomi"

# Build Target
## "recoveryimage" - for A-Only Devices without using Vendor Boot
## "bootimage" - for A/B devices without recovery partition (and without vendor boot)
## "vendorbootimage" - for devices Using vendor boot for the recovery ramdisk (Usually for devices shipped with Android 12 or higher)
export TARGET="recoveryimage"

export OUTPUT="OrangeFox*.zip"

# Additional Dependencies (eg: Kernel Source)
# Format: "repo dest"
DEPS=(
    "https://github.com/OrangeFoxRecovery/Avatar.git misc"
)

# Extra Command
export EXTRA_CMD="export OF_MAINTAINER=SpiDyNub"

# Magisk
## Use the Latest Release of Magisk for the OrangeFox addon
export OF_USE_LATEST_MAGISK=true

# Not Recommended to Change
export SYNC_PATH="$HOME/work" # Full (absolute) path.
export USE_CCACHE=false
export CCACHE_SIZE="50G"
export CCACHE_DIR="$HOME/work/.ccache"
export J_VAL=16

login_main () {
echo $my_og_token > mytoken.txt # login in github
gh auth login --with-token < mytoken.txt
}
