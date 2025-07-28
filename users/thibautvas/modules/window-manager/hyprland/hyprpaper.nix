{ config, lib, pkgs, ... }:

let
  paper = "$HOME/Pictures/Kath.png";

in {
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = paper;
      wallpaper = ",${paper}";
    };
  };
}
