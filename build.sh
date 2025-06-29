#!/bin/bash

mkdir rec
cd rec
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1

repo sync

git clone https://ImSpiDy:$my_og_token@github.com/Los-Ext/device_lavender_recovery device/xiaomi/lavender -b 12.1

#git clone https://github.com/Amritorock/device_realme_r5x_recovery device/realme/r5x

# Magisk
OF_USE_LATEST_MAGISK=0
if [[ $OF_USE_LATEST_MAGISK = "true" || $OF_USE_LATEST_MAGISK = "1" ]]; then
	echo "Downloading the Latest Release of Magisk..."
	LATEST_MAGISK_URL="$(curl -sL https://api.github.com/repos/topjohnwu/Magisk/releases/latest | jq -r . | grep browser_download_url | grep Magisk- | cut -d : -f 2,3 | sed 's/"//g')"
	mkdir -p ~/Magisk
	cd ~/Magisk
	aria2c $LATEST_MAGISK_URL 2>&1 || wget $LATEST_MAGISK_URL 2>&1
	echo "Magisk Downloaded Successfully"
	echo "Renaming .apk to .zip ..."
	#rename 's/.apk/.zip/' Magisk*
	mv $("ls" Magisk*.apk) $("ls" Magisk*.apk | sed 's/.apk/.zip/g')
	cd $SYNC_PATH >/dev/null
	echo "Done!"
fi

export ALLOW_MISSING_DEPENDENCIES=true

. build/envsetup.sh

lunch twrp_lavender-eng

mka recoveryimage

FILENAME=out/target/product/lavender/recovery.img

SERVER=$(curl -X GET 'https://api.gofile.io/servers' | grep -Po '(store*)[^"]*' | tail -n 1)
curl -X POST https://${SERVER}.gofile.io/contents/uploadfile -F "file=@$FILENAME" | grep -Po '(https://gofile.io/d/)[^"]*' > link.txt
DL_LINK=$(cat link.txt)
