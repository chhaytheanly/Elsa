{ config, pkgs, ... }:

{
  home.username = "yourusername";
  home.homeDirectory = "/home/yourusername";
  home.stateVersion = "24.05"; 
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    hyprland hyprlock hypridle hyprpaper
    waybar rofi swaync
  ];

  xdg.configFile = {
    "hypr/hyprland.lua".source = ./hyprland.lua;
    "hypr/hyprland".source = ./hyprland;       
    "hypr/hypridle.conf".source = ./hypridle.conf;
    "hypr/hyprlock.conf".source = ./hyprlock.conf;
    "hypr/hyprlock".source = ./hyprlock;       
    "rofi".source = ./rofi;
    "swaync".source = ./swaync;
    "waybar".source = ./waybar;
    
    "themes".source = ./themes;
  };

  home.file.".local/bin" = {
    source = ./scripts;
    recursive = true;
    executable = true; # Crucial: Makes all .sh files runnable
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {}; # We use xdg.configFile above, so keep this empty
    extraConfig = "";
  };
}