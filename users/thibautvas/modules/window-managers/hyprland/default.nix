{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # use system package
    portalPackage = null; # use system portalPackage
    configType = "lua";
    extraConfig = builtins.readFile ./settings.lua;
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
