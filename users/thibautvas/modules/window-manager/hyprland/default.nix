{ config, lib, pkgs, ... }:

{
  imports = [
    ./settings.nix
    ./bin.nix
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # use system package
    portalPackage = null; # use system portalPackage
  };

  home.packages = with pkgs; [
    hyprsunset
    hyprshot
    wl-clipboard
    cliphist
    wofi
    brightnessctl
    playerctl
  ];
}
