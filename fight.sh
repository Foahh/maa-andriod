#!/bin/bash
maa activity
maa update

if [ -z "$ADB_DEVICE" ]; then
    echo "Please set ADB_DEVICE environment variable"
    exit 1
fi
if [ -z "$ADB_DEVICE_PASSCODE" ]; then
    echo "Please set ADB_DEVICE_PASSCODE environment variable"
    exit 1
fi

# check if device is connected
if [ "$(adb devices | grep $ADB_DEVICE)" == "" ]; then
    adb connect $ADB_DEVICE
    if [ "$(adb devices | grep $ADB_DEVICE)" == "" ]; then
        echo "Device connection failed"
        exit 1
    fi
fi

echo "#############################################"

adb -s $ADB_DEVICE shell wm size 1080x1920
adb -s $ADB_DEVICE shell settings put system screen_brightness 1
maa run fight
adb -s $ADB_DEVICE shell wm size reset
adb -s $ADB_DEVICE shell settings put system screen_brightness 20

