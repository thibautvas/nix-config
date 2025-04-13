{ config, lib, pkgs, isLinux, ... }:

{
  services.hyprpaper = lib.mkIf isLinux {
    enable = true;
    settings = {
      preload = "$HOME/Pictures/Kath.png";
      wallpaper = ",$HOME/Pictures/Kath.png";
    };
  };
}
