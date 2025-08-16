{ config, lib, pkgs, ... }:

let
  mkBox = cmd: x: y: {
    text = cmd;
    color = "0xffffffff";
    font_size = 20;
    position = "${x}, ${y}";
    halign = "center";
    valign = "top";
  };

in {
  programs.hyprlock = {
    enable = true;
    settings = {
      background.path = "$HOME/Pictures/linux-nixos-7q-3840x2400.jpg";
      input-field = {
        size = "250, 50";
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.3;
        dots_center = true;
        color = "ffffffff";
        outline_color = "888888ff";
        position = "0, 20";
      };
      label = [
        (mkBox "cmd[update:30] date +\"%a %b %d %H:%M\"" "0" "-100")
        (mkBox "$USER" "0" "-140")
        (mkBox "cmd[update:1000] echo \"$(cat /sys/class/power_supply/BAT0/capacity)%\"" "700" "-180")
        (mkBox "cmd[update:1000] nmcli -g GENERAL.CONNECTION device show | head -n1" "700" "-100")
        (mkBox "cmd[update:1000] bluetoothctl info | awk -F ': ' '/Name: / {print $2}'" "700" "-140")
      ];
    };
  };
}
