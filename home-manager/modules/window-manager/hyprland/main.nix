{ config, pkgs, lib, ... }:

{
  imports = [
    ./settings.nix
    ./bin.nix
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  config = lib.mkIf config.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null; # set the hyprland package to null to use the one from the NixOS module
      portalPackage = null; # same with the xdg-desktop-portal-hyprland package
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
  };
}
