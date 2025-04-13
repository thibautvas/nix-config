{ config, lib, pkgs, isLinux, ... }:

{
  imports = [
    ./settings.nix
    ./bin.nix
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  wayland.windowManager.hyprland = lib.mkIf isLinux {
    enable = true;
    package = null; # use system package
    portalPackage = null; # use system portalPackage
  };

  home.packages = lib.optionals isLinux (with pkgs; [
    hyprsunset
    hyprshot
    wl-clipboard
    cliphist
    wofi
    brightnessctl
    playerctl
  ]);
}
