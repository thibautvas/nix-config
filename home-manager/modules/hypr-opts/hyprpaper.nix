{ config, pkgs, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = "$HOME/Pictures/Kath.png";
      wallpaper = ",$HOME/Pictures/Kath.png";
    };
  };
}
