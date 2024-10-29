#!/bin/bash
maa self update
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

# check if screen is unlocked
if [ "$(adb -s $ADB_DEVICE shell dumpsys window | grep mDreamingLockscreen | xargs)" == "mShowingDream=false mDreamingLockscreen=true" ]; then
    adb -s $ADB_DEVICE shell input keyevent 26
    adb -s $ADB_DEVICE shell input touchscreen swipe 200 900 200 300 1000
    adb -s $ADB_DEVICE shell input text $ADB_DEVICE_PASSCODE
    adb -s $ADB_DEVICE shell input keyevent 66
fi

# check if Arknights is running
if [[ "$(adb -s $ADB_DEVICE shell dumpsys window | grep mCurrentFocus | xargs)" != *"com.hypergryph.arknights/com.u8.sdk.U8UnityContext"* ]]; then
    adb -s $ADB_DEVICE shell am force-stop com.hypergryph.arknights
    adb -s $ADB_DEVICE shell am start -n com.hypergryph.arknights/com.u8.sdk.U8UnityContext

fi

echo "#############################################"

adb -s $ADB_DEVICE shell wm size 1080x1920
adb -s $ADB_DEVICE shell settings put system screen_brightness 1
maa run daily
adb -s $ADB_DEVICE shell wm size reset
adb -s $ADB_DEVICE shell settings put system screen_brightness 20

