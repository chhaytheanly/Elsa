#!/bin/bash
FLAG_FILE="/tmp/mako-dnd"

if [ -f "$FLAG_FILE" ]; then
    rm "$FLAG_FILE"
    makoctl set-paused -u
    notify-send -i notification -t 3000 "DND" "Notifications enabled"
else
    touch "$FLAG_FILE"
    makoctl set-paused -a
    notify-send -i notification -t 3000 "DND" "Notifications disabled"
fi
