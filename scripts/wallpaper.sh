#!/usr/bin/env bash

set -o pipefail

WALLPAPER_DIRS=(
    "$HOME/Pictures"
    "/usr/share/backgrounds"
)

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpapers/thumb"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprland/hyprpaper.conf"
ROFI_IMAGE="$HOME/.config/rofi/image.png"

mkdir -p "$CACHE_DIR"

declare -A thumbs
while IFS= read -r -d '' file; do
    [[ "$(file -b --mime-type "$file")" == image/* ]] || continue
    thumb="$CACHE_DIR/$(md5sum <<<"$file" | cut -d' ' -f1).jpg"
    if [[ ! -f "$thumb" ]]; then
        magick "$file" -thumbnail 300x200^ -gravity center -extent 300x200 -strip -quality 85 "$thumb"
    fi
    thumbs["$thumb"]="$file"
done < <(find "${WALLPAPER_DIRS[@]}" -mindepth 1 -maxdepth 1 -type f -print0 2>/dev/null)

[[ ${#thumbs[@]} -eq 0 ]] && exit 1

chosen=$(for thumb in "${!thumbs[@]}"; do
             printf '%s\0icon\x1f%s\n' "$thumb" "$thumb"
         done \
    | rofi -dmenu -show-icons \
        -theme-str 'imagebox { enabled: false; }' \
        -theme-str 'listview { lines: 8; padding: 12px; }' \
        -theme-str 'element { orientation: vertical; }' \
        -theme-str 'element-icon { size: 300px 200px; padding: 4px; }' \
        -theme-str 'element-text { enabled: false; }' \
        -theme-str 'prompt { enabled: false; }' \
        -theme-str 'entry { enabled: false; }')

[[ -z "$chosen" ]] && exit 0

wallpaper=$(realpath "${thumbs[$chosen]}")

for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
    hyprctl hyprpaper preload "$wallpaper"
    hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
done
hyprctl hyprpaper unload unused

magick "$wallpaper" -thumbnail 300x625^ -gravity center -extent 300x625 "$ROFI_IMAGE"

{
    echo "splash = false"
    echo
    while IFS= read -r monitor; do
        echo "wallpaper {"
        echo "    monitor = $monitor"
        echo "    path = $wallpaper"
        echo "    fit_mode = cover"
        echo "}"
        echo
    done < <(hyprctl monitors -j | jq -r '.[].name')
    echo "wallpaper {"
    echo "    monitor ="
    echo "    path = $wallpaper"
    echo "    fit_mode = cover"
    echo "}"
} > "$HYPRPAPER_CONF"