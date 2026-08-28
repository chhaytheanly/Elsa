# °˖\* ૮( • ᴗ ｡)っ🍸 Elsa

Welcome to my personal dotfiles! This repository houses configurations for a Wayland-based setup primarily utilizing Hyprland (configured via Lua) along with a suite of complementary tools and scripts.

## 📦 Requirements & Dependencies

To ensure these dotfiles work properly, you will need to install the following packages:

**Core Window Management & Desktop**

- **[Hyprland](https://hyprland.org/)** - The Wayland compositor
- **[hyprpaper](https://github.com/hyprwm/hyprpaper)** - Wallpaper utility
- **[hypridle](https://github.com/hyprwm/hypridle)** - Idle management daemon
- **[hyprlock](https://github.com/hyprwm/hyprlock)** - Screen locker

**Components & UI**

- **[Waybar](https://github.com/Alexays/Waybar)** - Highly customizable Wayland bar
- **[Rofi (Wayland)](https://github.com/lbonn/rofi-wayland)** - Application launcher (`rofi-wayland`)
- **[Mako](https://github.com/emersion/mako)** - Notification daemon
- **[Kitty](https://sw.kovidgoyal.net/kitty/)** - The default terminal emulator (defined in `keybinds.lua`)

**System Utilities**

- `xdg-desktop-portal-hyprland` - XDG Desktop Portal for screen sharing and Wayland integrations
- `polkit-gnome` - Authentication agent
- `network-manager-applet` (`nm-applet`) - Network management system tray icon
- `grim` & `slurp` - Screenshot utilities
- `wl-clipboard` - Command-line copy/paste utilities (`wl-copy`)
- `brightnessctl` - Backlight and brightness control
- `wireplumber` - Audio and volume control (`wpctl`)

_(Note: There are additional scripts in `scripts/extra/` which may require optional dependencies such as `ollama` for AI integrations, `fuzzel`, and `geoclue2` for location services depending on your usage)._

---

## 🚀 Setup Instructions

Follow these step-by-step instructions to deploy these dotfiles onto your system:

### 1. Install the Dependencies

Install all the required dependencies using your distribution's package manager. For example, on Arch Linux using `pacman`:

```bash
sudo pacman -S hyprland hyprpaper hypridle hyprlock waybar mako kitty grim slurp wl-clipboard brightnessctl wireplumber network-manager-applet polkit-gnome
```

_(Note: You may need an AUR helper like `yay` to install `rofi-wayland` depending on your distro)._

### 2. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/chhaytheanly/Elsa.git ~/Elsa-Dotfiles
```

### 3. Backup Existing Configurations

If you already have existing configurations for Hyprland or Waybar, it's highly recommended to back them up first:

```bash
mv ~/.config/hypr ~/.config/hypr.backup
```

### 4. Link the Dotfiles

Symlink (or copy) the cloned repository directory to `~/.config/hypr` so your system automatically applies the configuration:

```bash
ln -s ~/Elsa-Dotfiles ~/.config/hypr
```

### 5. Make Scripts Executable

Ensure that the provided shell scripts (such as the powermenu and extra AI scripts) have the correct execution permissions:

```bash
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/hypr/scripts/extra/*.sh
chmod +x ~/.config/hypr/scripts/extra/ai/*.sh
```

### 6. Enjoy!

Log out of your current desktop session (or start from a TTY) and launch Hyprland. Your new environment, complete with keybindings, Waybar, and visual themes, should now be fully active!
