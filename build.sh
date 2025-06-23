#!/bin/bash

sudo apt update
sudo apt install -y gnupg-agent gpg-agent pinentry-curses

FOX_SYNC="https://gitlab.com/OrangeFox/sync.git"
CONFIG="config.sh"

TG_CHAT_ID="-1001734041926"
TG_TOKEN="1921250592:AAFnoXSBt2iw2Vve1yUVpvPqvFicxjOtIkY"

CIRRUS_SHELL=bash

. scripts/checks.sh

. scripts/sync.sh

. scripts/build.sh

. scripts/upload.sh
