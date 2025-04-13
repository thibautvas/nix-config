{ config, lib, pkgs, isLinux, ... }:

{
  wayland.windowManager.hyprland.settings = lib.mkIf isLinux {
    exec-once = [
      "hyprsunset --temperature 2000"
      "wl-paste --type text --watch cliphist store"
    ];

    monitor = [
      "eDP-1,1920x1080@60,0x0,1.25"
      "HDMI-A-1,3840x2160@30,1920x0,1.5"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 0;
      border_size = 1;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      layout = "dwindle";
    };

    decoration.blur.enabled = false;
    animations.enabled = false;
    misc.disable_hyprland_logo = true;

    windowrulev2 = [
      "bordersize 0, onworkspace:w[tv1]"
      "workspace 1, class:firefox"
      "workspace 2, class:com.mitchellh.ghostty"
      "suppressevent maximize, class:.*"
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
    ];

    bind = [
      "super, r, exec, wofi --gtk-dark --show drun"
      "alt-ctrl-shift-super, f, exec, hyprctl-launch firefox firefox"
      "alt-ctrl-shift-super, d, exec, hyprctl-launch ghostty com.mitchellh.ghostty"
      "alt-ctrl-shift-super, v, exec, hyprctl-launch-alt firefox firefox 2"
      "alt-ctrl-shift-super, tab, cyclenext"
      "alt, f, workspace, 1"
      "alt, d, workspace, 2"
      "alt, s, workspace, 3"
      "alt-shift, f, movetoworkspace, 1"
      "alt-shift, d, movetoworkspace, 2"
      "alt-shift, s, movetoworkspace, 3"
      "super, f, togglefloating"
      "super, c, killactive"
      "super, l, exec, hyprlock"
      "super, m, exit"
      "super, s, exec, hyprshot -m region -f \"Pictures/$(date +%Y-%m-%d-%H%M%S)_hyprshot.png\""
      "shift-super, s, exec, hyprshot -m window -f \"Pictures/$(date +%Y-%m-%d-%H%M%S)_hyprshot.png\""
      "super, v, exec, cliphist list | wofi --gtk-dark --dmenu | cliphist decode | wl-copy"
      "super, p, exec, sup | wofi --gtk-dark --dmenu"
      "super, b, exec, btc \"$(echo -e 'speakers\\n headset' | wofi --gtk-dark --dmenu)\""
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
      follow_mouse = 0;
      sensitivity = 1;
      touchpad.natural_scroll = true;
    };
  };
}
