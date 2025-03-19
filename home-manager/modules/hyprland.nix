{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # set the hyprland package to null to use the one from the NixOS module
    portalPackage = null; # same with the xdg-desktop-portal-hyprland package
  };

  imports = [
    ./hypr-opts/hyprpaper.nix
    ./hypr-opts/hypridle.nix
    ./hypr-opts/hyprlock.nix
    ./hypr-opts/settings.nix
  ];
}
