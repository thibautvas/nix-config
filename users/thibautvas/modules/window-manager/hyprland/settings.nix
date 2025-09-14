{ config, lib, pkgs, ... }:

let
  browser = {
    bin = "zen-twilight";
    class = "zen-twilight";
  };
  terminal = {
    bin = "ghostty";
    class = "com.mitchellh.ghostty";
  };

in {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "hyprsunset --temperature 2000"
      "wl-paste --type text --watch cliphist store"
      "hrm"
      "$HOME/repos/alt/kill_leds"
    ];

    monitor = [
      "eDP-1,1920x1200@60,0x0,1.5"
      "HDMI-A-1,3840x2160@60,1920x0,1.5"
    ];

    general = {
      gaps_in = 2;
      gaps_out = 0;
      border_size = 1;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      layout = "master";
    };

    master.mfact = 0.5;
    decoration.blur.enabled = false;
    animations.enabled = false;
    misc.disable_hyprland_logo = true;

    windowrulev2 = [
      "bordersize 0, onworkspace:w[tv1]"
      "workspace 1, class:${browser.class}"
      "workspace 2, class:${terminal.class}"
      "suppressevent maximize, class:.*"
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
    ];

    bind = [
      "super, j, exec, hyprctl-launch ${browser.bin} ${browser.class}"
      "super, k, exec, hyprctl-launch ${terminal.bin} ${terminal.class}"
      "super, n, exec, hyprctl-launch-alt ${browser.bin} ${browser.class} 2"
      "super, o, fullscreen"
      "super, p, layoutmsg, swapwithmaster"
      "super, tab, cyclenext"
      "alt, j, workspace, 1"
      "alt, k, workspace, 2"
      "alt, l, workspace, 3"
      "alt-shift, j, movetoworkspace, 1"
      "alt-shift, k, movetoworkspace, 2"
      "alt-shift, l, movetoworkspace, 3"
      "super, r, exec, wofi --gtk-dark --show drun"
      "super, f, togglefloating"
      "super, c, killactive"
      "super, q, exec, hyprlock"
      "super, m, exit"
      "super, s, exec, hyprshot -m region -f \"Pictures/$(date +%Y-%m-%d-%H%M%S)_hyprshot.png\""
      "shift-super, s, exec, hyprshot -m window -f \"Pictures/$(date +%Y-%m-%d-%H%M%S)_hyprshot.png\""
      "super, v, exec, cliphist list | wofi --gtk-dark --dmenu | cliphist decode | wl-copy"
      "super, h, exec, sup | wofi --gtk-dark --dmenu"
    ];

    bindel = [
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];

    bindl = [
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];

    input = {
      kb_layout = "us(mac)";
      follow_mouse = 0;
      sensitivity = 1;
      touchpad.natural_scroll = true;
    };

    cursor = {
      hide_on_key_press = true;
      no_warps = true;
    };
  };
}
