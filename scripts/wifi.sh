#!/usr/bin/env bash

theme="$HOME/.config/rofi/theme.rasi"
theme_str='window { width: 460px; } imagebox { enabled: false; } listview { lines: 12; }'
rofi_cmd=(rofi -dmenu -i -p "Wifi" -theme "$theme" -theme-str "$theme_str")

iface=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi"{print $1; exit}')
[[ -z "$iface" ]] && { notify-send "Wifi" "No wireless device found"; exit 1; }

current=$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2=="802-11-wireless"{print $1; exit}')

bars() {
    local s=$1
    if   (( s >= 80 )); then echo "󰤨"
    elif (( s >= 60 )); then echo "󰤥"
    elif (( s >= 40 )); then echo "󰤢"
    elif (( s >= 20 )); then echo "󰤟"
    else                     echo "󰤯"
    fi
}

build_menu() {
    [[ -n "$current" ]] && printf 'Disconnect\t\t\t%s\n' "󰖪"
    while IFS=: read -r ssid signal security; do
        [[ -z "$ssid" || "$ssid" == "--" ]] && continue
        [[ "$ssid" != *"\\"* ]] && ssid="${ssid//\\:/:}"
        mark="  "
        [[ "$ssid" == "$current" ]] && mark="* "
        printf '%s%s\t%s  %s%%\t%s\n' "$mark" "$ssid" "$(bars "$signal")" "$signal" "$security"
    done < <(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list ifname "$iface")
}

nmcli device wifi rescan >/dev/null 2>&1
sleep 1

chosen=$(build_menu | "${rofi_cmd[@]}")
[[ -z "$chosen" ]] && exit 0

ssid=$(printf '%s' "$chosen" | cut -f1 | sed 's/^\* //; s/^  //')

if [[ "$ssid" == "Disconnect" ]]; then
    nmcli connection down id "$current" && notify-send "Wifi" "Disconnected from $current"
    exit 0
fi

if [[ "$ssid" == "$current" ]]; then
    nmcli connection down id "$current"
    exit 0
fi

if nmcli -t -f NAME connection show | grep -qxF "$ssid"; then
    nmcli connection up id "$ssid" && notify-send "Wifi" "Connected to $ssid"
    exit 0
fi

security=$(printf '%s' "$chosen" | cut -f3)
pass=""
if [[ "$security" != "--" && -n "$security" ]]; then
    pass=$(rofi -dmenu -password -p "Password" -theme "$theme" -theme-str 'window { width: 350px; } imagebox { enabled: false; }')
    [[ -z "$pass" ]] && exit 1
fi

if nmcli device wifi connect "$ssid" ${pass:+password "$pass"} ifname "$iface" >/dev/null 2>&1; then
    notify-send "Wifi" "Connected to $ssid"
else
    notify-send "Wifi" "Failed to connect to $ssid"
    exit 1
fi
