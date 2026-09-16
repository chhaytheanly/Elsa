{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ]; 

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [ git vim neovim ];

  users.users.yourusername = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  system.stateVersion = "24.05";
}