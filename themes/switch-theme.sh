#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  °˖* ૮(  • ᴗ ｡)っ🍸  Theme Switcher
# ═══════════════════════════════════════════════════════════════
#  Usage:  ./switch-theme.sh <theme>
#  Example: ./switch-theme.sh tokyo-night
#            ./switch-theme.sh cyan
#            ./switch-theme.sh everforest

THEMES_DIR="$(cd "$(dirname "$0")" && pwd)"
CURRENT_LINK="$THEMES_DIR/current"

# ── List available themes ──────────────────────────────────────
list_themes() {
    echo "Available themes:"
    for dir in "$THEMES_DIR"/*/; do
        theme=$(basename "$dir")
        [[ "$theme" == "base" || "$theme" == "current" ]] && continue
        [[ -f "$dir/colors.css" ]] && echo "  - $theme"
    done
}

# ── Validate theme ─────────────────────────────────────────────
if [[ -z "$1" ]]; then
    echo "Usage: $0 <theme>"
    echo ""
    list_themes
    exit 1
fi

THEME_DIR="$THEMES_DIR/$1"

if [[ ! -d "$THEME_DIR" ]]; then
    echo "Error: Theme '$1' not found."
    echo ""
    list_themes
    exit 1
fi

if [[ ! -f "$THEME_DIR/colors.css" ]]; then
    echo "Error: '$1' is missing colors.css. Is it a valid theme?"
    exit 1
fi

# ── Switch theme ───────────────────────────────────────────────
echo "Switching to theme: $1"

rm -f "$CURRENT_LINK"
ln -sfn "$THEME_DIR" "$CURRENT_LINK"

# ── Reload components ──────────────────────────────────────────
if command -v hyprctl &>/dev/null; then
    hyprctl reload 2>/dev/null && echo "  ✓ Hyprland reloaded"
fi

if pgrep -x waybar &>/dev/null; then
    killall -SIGUSR2 waybar 2>/dev/null && echo "  ✓ Waybar reloaded"
fi

if command -v swaync-client &>/dev/null; then
    swaync-client -rs 2>/dev/null && echo "  ✓ SwayNC reloaded"
fi

echo ""
echo "Theme switched to: $1"
