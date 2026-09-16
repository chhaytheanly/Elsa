#!/usr/bin/env bash
# ── Theme Switcher ─────────────────────────────────────────
# °˖* ૮(  • ᴗ ｡)っ🍸 applies themes to waybar, swaync, rofi and hyprland

set -euo pipefail

CFG_DIR="${HOME}/.config/hypr"
THEME_DIR="${CFG_DIR}/themes"
STATE_FILE="${CFG_DIR}/.current_theme"

# ── Helpers ────────────────────────────────────────────────

get_available_themes() {
    for d in "${THEME_DIR}"/*; do
        [[ -d "$d" && ! -L "$d" ]] || continue
        local name
        name=$(basename "$d")
        [[ "$name" == "base" ]] && continue
        [[ -f "$d/colors.css" ]] && echo "$name"
    done
}

get_current_theme() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo "cyan"
    fi
}

# ── Apply theme ────────────────────────────────────────────

apply_theme() {
    local theme_name="$1"
    local theme_path="${THEME_DIR}/${theme_name}"

    if [[ ! -d "$theme_path" ]]; then
        echo "Theme '${theme_name}' not found in ${THEME_DIR}" >&2
        return 1
    fi

    # ── Generate configs from base/ + colors ────────────────
    local base_dir="${THEME_DIR}/base"
    cat "${theme_path}/colors.css" "${base_dir}/waybar.css"  > "${CFG_DIR}/waybar/style.css"
    cat "${theme_path}/colors.css" "${base_dir}/swaync.css"  > "${CFG_DIR}/swaync/style.css"
    { cat "${theme_path}/colors.rasi"; echo; cat "${base_dir}/rofi.rasi"; } > "${CFG_DIR}/rofi/theme.rasi"

    # ── Modify general.lua directly ────────────────────────
    if [[ -f "${theme_path}/hyprland.conf" ]]; then
        # shellcheck disable=SC1090
        source "${theme_path}/hyprland.conf"
        sed -i "s/active_border   = \".*\"/active_border   = \"${HYPR_ACTIVE}\"/g" "${CFG_DIR}/hyprland/general.lua"
        sed -i "s/inactive_border = \".*\"/inactive_border = \"${HYPR_INACTIVE}\"/g" "${CFG_DIR}/hyprland/general.lua"
    fi

    # ── Save state BEFORE reload ───────────────────────────
    echo "$theme_name" > "$STATE_FILE"

    # ── Hyprland: re-evaluate lua config ───────────────────
    hyprctl reload >/dev/null 2>&1 || true

    # ── Restart services ───────────────────────────────────
    pkill waybar 2>/dev/null || true
    sleep 0.3
    waybar -c "${CFG_DIR}/waybar/config" -s "${CFG_DIR}/waybar/style.css" >/dev/null 2>&1 &
    disown

    pkill swaync 2>/dev/null || true
    sleep 0.2
    swaync -c "${CFG_DIR}/swaync/config.json" -s "${CFG_DIR}/swaync/style.css" >/dev/null 2>&1 &
    disown

    echo "Theme switched to: ${theme_name}"
}

# ── Rofi picker ────────────────────────────────────────────

pick_theme() {
    local current
    current="$(get_current_theme)"
    local theme_path="${THEME_DIR}/${current}"

    local list=""
    local t
    while IFS= read -r t; do
        if [[ "$t" == "$current" ]]; then
            list+="● ${t}  (current)\n"
        else
            list+="○ ${t}\n"
        fi
    done < <(get_available_themes)
    list="${list%\\n}"

    local picker_tmp="${CFG_DIR}/.picker_theme.rasi"
    { cat "${theme_path}/colors.rasi"; echo; cat "${THEME_DIR}/base/picker.rasi"; } > "$picker_tmp"

    local chosen
    chosen=$(printf '%b' "$list" | rofi -dmenu -p " theme" -theme "$picker_tmp")

    if [[ -z "$chosen" ]]; then
        return 0
    fi

    local selected
    selected=$(echo "$chosen" | sed 's/^[●○ ]*//; s/  (current)$//')

    apply_theme "$selected"
}

# ── Cycle to next theme ────────────────────────────────────

cycle_theme() {
    local current
    current="$(get_current_theme)"

    local themes=()
    while IFS= read -r t; do
        themes+=("$t")
    done < <(get_available_themes)

    local count=${#themes[@]}
    if (( count <= 1 )); then
        echo "Only one theme available, nothing to cycle" >&2
        return 1
    fi

    local idx=0
    for i in "${!themes[@]}"; do
        if [[ "${themes[$i]}" == "$current" ]]; then
            idx=$i
            break
        fi
    done

    local next_idx=$(( (idx + 1) % count ))
    apply_theme "${themes[$next_idx]}"
}

# ── List themes ────────────────────────────────────────────

list_themes() {
    local current
    current="$(get_current_theme)"
    echo "Available themes:"
    while IFS= read -r t; do
        if [[ "$t" == "$current" ]]; then
            echo "  * ${t}  (current)"
        else
            echo "    ${t}"
        fi
    done < <(get_available_themes)
}

# ── Main ───────────────────────────────────────────────────

case "${1:-}" in
    "")
        pick_theme
        ;;
    --cycle|-c)
        cycle_theme
        ;;
    --list|-l)
        list_themes
        ;;
    --current)
        get_current_theme
        ;;
    *)
        apply_theme "$1"
        ;;
esac