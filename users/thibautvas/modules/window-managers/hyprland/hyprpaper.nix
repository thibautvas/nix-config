{
  config,
  lib,
  pkgs,
  ...
}:

let
  paper = "$HOME/Pictures/linux-nixos-7q-3840x2400.jpg";

in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = {
        monitor = "";
        path = paper;
      };
      splash = false;
    };
  };
}
