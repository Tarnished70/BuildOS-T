#!/bin/bash

. /tmp/sgsi/function

# Notification
tg "SGSI Build Started!
Status: $progress"

sudo bash LinkToGSI.sh https://dl.google.com/dl/android/aosp/lynx-bp1a.250505.005.b1-factory-45a1393f.zip Pixel
