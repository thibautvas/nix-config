{ config, pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    settings = {
      background.path = "$HOME/Pictures/Kath.png";
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
        {
          text = "cmd[update:30] date +\"%a %b %d %H:%M\"";
          color = "0xffffffff";
          font_size = 20;
          position = "0, -100";
          halign = "center";
          valign = "top";
        }
        {
          text = "$USER";
          color = "0xffffffff";
          font_size = 20;
          position = "0, -140";
          halign = "center";
          valign = "top";
        }
        {
          text = "cmd[update:1000] echo \"$(cat /sys/class/power_supply/BAT1/capacity)%\"";
          color = "0xffffffff";
          font_size = 20;
          position = "700, -180";
          halign = "center";
          valign = "top";
        }
        {
          text = "cmd[update:1000] nmcli -g GENERAL.CONNECTION device show | head -n1";
          color = "0xffffffff";
          font_size = 20;
          position = "700, -100";
          halign = "center";
          valign = "top";
        }
        {
          text = "cmd[update:1000] bluetoothctl info | grep 'Name' | cut -d':' -f2 | xargs";
          color = "0xffffffff";
          font_size = 20;
          position = "700, -140";
          halign = "center";
          valign = "top";
        }
      ];
    };
  };
}
