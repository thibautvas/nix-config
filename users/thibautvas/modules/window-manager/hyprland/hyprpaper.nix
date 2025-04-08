{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.hyprland.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = "$HOME/Pictures/Kath.png";
        wallpaper = ",$HOME/Pictures/Kath.png";
      };
    };
  };
}
