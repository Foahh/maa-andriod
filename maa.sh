#!/bin/bash

maa_update() {
    maa self update
    maa activity
    maa update
}

check_env_vars() {
    if [ -z "$ADB_DEVICE" ]; then
        echo "Please set ADB_DEVICE environment variable"
        exit 1
    fi
    if [ -z "$ADB_DEVICE_PASSCODE" ]; then
        echo "Please set ADB_DEVICE_PASSCODE environment variable"
        exit 1
    fi
}

connect_device() {
    if [ "$(adb devices | grep $ADB_DEVICE)" == "" ]; then
        adb connect $ADB_DEVICE
        if [ "$(adb devices | grep $ADB_DEVICE)" == "" ]; then
            echo "Device connection failed"
            exit 1
        fi
    fi
}

unlock_screen() {
    if [ "$(adb -s $ADB_DEVICE shell dumpsys window | grep mDreamingLockscreen | xargs)" == "mShowingDream=false mDreamingLockscreen=true" ]; then
        adb -s $ADB_DEVICE shell input keyevent 26
        adb -s $ADB_DEVICE shell input touchscreen swipe 200 900 200 300 1000
        adb -s $ADB_DEVICE shell input text $ADB_DEVICE_PASSCODE
        adb -s $ADB_DEVICE shell input keyevent 66
    fi
}

start_arknights() {
    if [[ "$(adb -s $ADB_DEVICE shell dumpsys window | grep mCurrentFocus | xargs)" != *"com.hypergryph.arknights/com.u8.sdk.U8UnityContext"* ]]; then
        adb -s $ADB_DEVICE shell am force-stop com.hypergryph.arknights
        adb -s $ADB_DEVICE shell am start -n com.hypergryph.arknights/com.u8.sdk.U8UnityContext
    fi
}

set_screen_params() {
    local action=$1
    if [ "$action" == "pre" ]; then
        adb -s $ADB_DEVICE shell wm size 1080x1920
        adb -s $ADB_DEVICE shell settings put system screen_brightness 1
        adb -s $ADB_DEVICE shell settings put system screen_off_timeout 86400000
    elif [ "$action" == "post" ]; then
        adb -s $ADB_DEVICE shell wm size reset
        adb -s $ADB_DEVICE shell settings put system screen_brightness 20
        adb -s $ADB_DEVICE shell settings put system screen_off_timeout 60000
    fi
}

run_maa_action() {
    local action=$1
    set_screen_params "pre"
    maa run $action
    set_screen_params "post"
}

usage() {
    echo "Usage: $0 [fight|daily]"
    exit 1
}

main() {
    if [ $# -ne 1 ]; then
        usage
    fi

    local action=$1

    maa_update

    check_env_vars

    connect_device

    unlock_screen

    export MAA_CONFIG_DIR="."

    if [ "$action" == "daily" ]; then
        start_arknights
    fi

    echo "#############################################"

    run_maa_action $action
}

main "$@"