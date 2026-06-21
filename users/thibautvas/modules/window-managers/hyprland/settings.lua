---@diagnostic disable: undefined-global

local browser = { bin = "zen-twilight", class = "zen-twilight" }
local terminal = { bin = "ghostty", class = "com.mitchellh.ghostty" }

hl.on("hyprland.start", function()
  hl.exec_cmd("hyprsunset --temperature 2000")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("hrm")
end)

hl.config({
  animations = { enabled = false },
  cursor = {
    hide_on_key_press = true,
    no_warps = true,
  },
  input = {
    kb_layout = "us(mac)",
    follow_mouse = 0,
    sensitivity = 1,
    touchpad = { natural_scroll = true },
  },
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
    layout = "master",
  },
  master = { mfact = 0.5 },
})

hl.monitor({ output = "eDP-1", mode = "1920x1200", position = "0x0", scale = 1.5 })
hl.monitor({ output = "DP-2", mode = "3840x2160", position = "1920x0", scale = 2 })

hl.workspace_rule({ workspace = "1", monitor = "DP-2" })
hl.workspace_rule({ workspace = "2", monitor = "DP-2" })
hl.workspace_rule({ workspace = "3", monitor = "eDP-1" })

hl.window_rule({
  name = "browser J",
  match = { class = browser.class },
  workspace = 1
})
hl.window_rule({
  name = "terminal K",
  match = { class = terminal.class },
  workspace = 2
})

local hl_launch = function(bin, class)
  local wins = hl.get_windows()
  for _, w in pairs(wins) do
    if w.class == class then
      hl.dispatch(hl.dsp.focus({ window = "class:" .. class }))
      return
    end
  end
  hl.dispatch(hl.dsp.exec_cmd(bin))
end

hl.bind("SUPER + M", hl.dsp.exit())
hl.bind("SUPER + Q", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("wofi --gtk-dark --show drun"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | wofi --gtk-dark --dmenu -i | cliphist decode | wl-copy"))
hl.bind("SUPER + H", hl.dsp.exec_cmd("sup | wofi --gtk-dark --dmenu"))
hl.bind("SUPER + 1", hl.dsp.exec_cmd("PICKER='wofi --gtk-dark --dmenu -i' run-mp3"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("hyprshot -m region -f \"Pictures/$(date +%Y-%m-%d-%H%M%S)_hyprshot.png\""))
hl.bind("SHIFT + SUPER + S", hl.dsp.exec_cmd("hyprshot -m window -f \"Pictures/$(date +%Y-%m-%d-%H%M%S)_hyprshot.png\""))
hl.bind("SUPER + J", function() hl_launch(browser.bin, browser.class) end)
hl.bind("SUPER + K", function() hl_launch(terminal.bin, terminal.class) end)
hl.bind("SUPER + TAB", hl.dsp.window.cycle_next())
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + O", hl.dsp.window.fullscreen())
hl.bind("SUPER + F", hl.dsp.window.float())
hl.bind("SUPER + P", hl.dsp.layout("swapwithmaster"))
hl.bind("ALT + J", hl.dsp.focus({ workspace = 1 }))
hl.bind("ALT + K", hl.dsp.focus({ workspace = 2 }))
hl.bind("ALT + L", hl.dsp.focus({ workspace = 3 }))
hl.bind("ALT + SHIFT + J", hl.dsp.window.move({ workspace = 1 }))
hl.bind("ALT + SHIFT + K", hl.dsp.window.move({ workspace = 2 }))
hl.bind("ALT + SHIFT + L", hl.dsp.window.move({ workspace = 3 }))
hl.bind("ALT + SHIFT + N", function()
  hl.dispatch(hl.dsp.window.move({ window = "class:" .. terminal.class, workspace = 1 }))
end)
hl.bind("ALT + SHIFT + M", function()
  hl.dispatch(hl.dsp.window.move({ window = "class:" .. browser.class, workspace = 1 }))
  hl.dispatch(hl.dsp.window.move({ window = "class:" .. terminal.class, workspace = 2 }))
end)

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"))

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

hl.bind("SHIFT + SUPER + 0", function()
  for _, m in pairs(hl.get_monitors()) do
    if m.name == "DP-2" then
      hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ monitor = "eDP-1" }))
      end, { timeout = 500, type = "oneshot" })
    end
  end
end)
