#!/usr/bin/env bash

confirm() {
    local ans
    ans=$(printf "No\nYes" | rofi -dmenu -p "$1?" -theme-str 'window { width: 22%; } listview { lines: 2; }')
    [[ "$ans" == "Yes" ]]
}

chosen=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown\nCancel" \
    | rofi -dmenu -p "Power" \
    -theme-str 'window { width: 24%; } listview { lines: 6; spacing: 6px; }')

case "$chosen" in
    "Lock")
        hyprlock
        ;;
    "Logout")
        confirm "Logout" && hyprctl dispatch exit
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Reboot")
        confirm "Reboot" && systemctl reboot
        ;;
    "Shutdown")
        confirm "Shutdown" && systemctl poweroff
        ;;
    *)
        exit 0
        ;;
esac
