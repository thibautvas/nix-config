const ebro = @import("ebro");

pub const workspace_count = 4;
pub const workspace_outputs = [workspace_count]?[]const u8{ "DP-2", "DP-2", "DP-2", "eDP-1" };

pub const autostart = [_][:0]const u8{
    "kanshi",
    "wlsunset -t 2000 -T 2001",
    "hypridle",
    "wl-paste -t text -w cliphist store",
    "foot --server",
};

pub const keyboard: ebro.Keyboard = .{ .repeat_rate = 50, .repeat_delay = 200 };

const browser = "firefox";
const terminal = "footclient";

pub const rules = [_]ebro.Rule{
    .{ .app_id = browser, .workspace = 1 },
    .{ .app_id = terminal, .workspace = 2 },
};

const Mods = @FieldType(ebro.Bind, "mods");

const none: Mods = .{};
const alt: Mods = .{ .mod1 = true };
const alt_shift: Mods = .{ .mod1 = true, .shift = true };
const super: Mods = .{ .mod4 = true };
const super_shift: Mods = .{ .mod4 = true, .shift = true };

const tab = 0xff09;

const mon_brightness_up = 0x1008ff02;
const mon_brightness_down = 0x1008ff03;
const audio_raise_volume = 0x1008ff13;
const audio_lower_volume = 0x1008ff11;
const audio_mute = 0x1008ff12;

const audio_next = 0x1008ff17;
const audio_prev = 0x1008ff16;
const audio_play = 0x1008ff14;
const audio_pause = 0x1008ff31;

pub const binds = [_]ebro.Bind{
    .{ .mods = super, .keysym = 'h', .action = .{ .spawn = "sup | wofi --gtk-dark --dmenu" } },
    .{ .mods = super, .keysym = 'v', .action = .{ .spawn = "cliphist list | wofi --gtk-dark --dmenu -i | cliphist decode | wl-copy" } },
    .{ .mods = super, .keysym = 'r', .action = .{ .spawn = "wofi --gtk-dark --show drun" } },
    .{ .mods = super, .keysym = '1', .action = .{ .spawn = "PICKER='wofi --gtk-dark --dmenu -i' run-mp3" } },

    .{ .mods = super, .keysym = 'j', .action = .{ .launch_or_focus = .{ .app_id = browser, .cmd = browser } } },
    .{ .mods = super, .keysym = 'k', .action = .{ .launch_or_focus = .{ .app_id = terminal, .cmd = terminal } } },
    .{ .mods = alt, .keysym = 'j', .action = .{ .focus_workspace = 1 } },
    .{ .mods = alt, .keysym = 'k', .action = .{ .focus_workspace = 2 } },
    .{ .mods = alt, .keysym = 'l', .action = .{ .focus_workspace = 3 } },
    .{ .mods = alt, .keysym = ';', .action = .{ .focus_workspace = 4 } },
    .{ .mods = alt_shift, .keysym = 'j', .action = .{ .move_to_workspace = 1 } },
    .{ .mods = alt_shift, .keysym = 'k', .action = .{ .move_to_workspace = 2 } },
    .{ .mods = alt_shift, .keysym = 'l', .action = .{ .move_to_workspace = 3 } },
    .{ .mods = alt_shift, .keysym = ';', .action = .{ .move_to_workspace = 4 } },

    .{ .mods = super, .keysym = tab, .action = .focus_next },
    .{ .mods = super, .keysym = 'p', .action = .swap_master },
    .{ .mods = super, .keysym = 'o', .action = .toggle_fullscreen },
    .{ .mods = super, .keysym = 'c', .action = .close },
    .{ .mods = super, .keysym = 'm', .action = .exit },
    .{ .mods = super, .keysym = 'q', .action = .{ .spawn = "hyprlock" } },
    .{ .mods = alt_shift, .keysym = '0', .action = .{ .spawn = "wlopm --toggle eDP-1" } },

    .{ .mods = super, .keysym = 's', .action = .{ .spawn = "grim -g \"$(slurp)\" $HOME/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png" } },
    .{ .mods = super_shift, .keysym = 's', .action = .{ .spawn = "grim $HOME/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png" } },

    .{ .mods = none, .keysym = mon_brightness_up, .action = .{ .spawn = "brightnessctl -e4 -n2 set 5%+" } },
    .{ .mods = none, .keysym = mon_brightness_down, .action = .{ .spawn = "brightnessctl -e4 -n2 set 5%-" } },
    .{ .mods = none, .keysym = audio_raise_volume, .action = .{ .spawn = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" } },
    .{ .mods = none, .keysym = audio_lower_volume, .action = .{ .spawn = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" } },
    .{ .mods = none, .keysym = audio_mute, .action = .{ .spawn = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" }, .locked = true },

    .{ .mods = none, .keysym = audio_next, .action = .{ .spawn = "playerctl next" } },
    .{ .mods = none, .keysym = audio_prev, .action = .{ .spawn = "playerctl previous" } },
    .{ .mods = none, .keysym = audio_play, .action = .{ .spawn = "playerctl play-pause" }, .locked = true },
    .{ .mods = none, .keysym = audio_pause, .action = .{ .spawn = "playerctl play-pause" }, .locked = true },
};
