{ config, lib, pkgs, isDarwin, isLinux, ... }:

let
  cfg = {
    darwin = {
      input.base = "iokit-name";
      output = "kext";
      ctlMet = "M";
      altCtl = "A";
      start = "M-left";
      end = "M-right";
    };
    linux = {
      input = {
        base = "device-file \"/dev/input/by-path/platform-i8042-serio-0-event-kbd\"";
        extended = "device-file \"/dev/input/by-id/usb-Keychron_Keychron_V4-event-kbd\"";
      };
      output = "uinput-sink \"output\"";
      ctlMet = "C";
      altCtl = "C";
      start = "home";
      end = "end";
    };
  };

  mkHomeRowMods = platform: inputDevice: ''
    (defcfg
      input (${cfg.${platform}.input.${inputDevice}})
      output (${cfg.${platform}.output})
      fallthrough true
      allow-cmd true
    )

    (defalias
      ;; home row mods (AMSC)
      alt_a (tap-hold-next-release 200 a lalt)
      met_s (tap-hold-next-release 200 s lmet)
      sft_d (tap-hold-next-release 200 d lsft)
      ctl_f (tap-hold-next-release 200 f lctl)
      ctl_j (tap-hold-next-release 200 j rctl)
      sft_k (tap-hold-next-release 200 k rsft)
      met_l (tap-hold-next-release 200 l rmet)
      alt_; (tap-hold-next-release 200 ; ralt)

      ;; hyper
      hyp (around rmet (around ralt (around rctl rsft)))
      hyp_h (tap-hold-next-release 200 h @hyp)

      ;; navigation layer
      nav (layer-toggle nav)
      nav_esc (tap-hold-next-release 200 esc @nav)
      vim_d #(${cfg.${platform}.ctlMet}-x)
      vim_y #(${cfg.${platform}.ctlMet}-c)
      vim_p #(${cfg.${platform}.ctlMet}-v)
      vim_b #(${cfg.${platform}.altCtl}-left)
      vim_w #(${cfg.${platform}.altCtl}-right)
      vim_^ ${cfg.${platform}.start}
      vim_$ ${cfg.${platform}.end}
      vim_V #(${cfg.${platform}.start} S-${cfg.${platform}.end})
      vim_S #(${cfg.${platform}.end} S-${cfg.${platform}.start} bspc)
      vim_o #(${cfg.${platform}.end} S-ret)

      ;; comfort layer: email addresses and accessible controls for 60% keyboard
      com (layer-toggle com)
      com_tab (tap-hold-next-release 200 tab @com)
      gmail #(t h i b a u t . v a s @ g m a i l . c o m)

      ;; restart aerospace
      ar (cmd-button "aerospace-restart")
    )

    (defsrc
      esc       f1        f2        f3        f4        f5        f6        f7        f8        f9        f10       f11       f12
                1         2         3         4         5         6         7         8         9         0         -         =         bspc
      tab                                                         y         u         i         o         p         [         ]
      caps      a         s         d         f                   h         j         k         l         ;
                                                                            m         ,         .
    )

    (deflayer mod
      grv       brdn      brup      mctl      @ar       bldn      blup      prev      pp        next      mute      vold      volu
                _         _         _         _         _         _         _         _         _         _         _         _         _
      @com_tab                                                    _         _         _         _         _         _         _
      @nav_esc  @alt_a    @met_s    @sft_d    @ctl_f              @hyp_h    @ctl_j    @sft_k    @met_l    @alt_;
                                                                            _         _         _
    )

    (deflayer nav
      _         f1        f2        f3        f4        f5      f6          f7        f8        f9        f10       f11       f12
                _         _         _         _         _       _           S-@vim_b  S-@vim_w  @vim_V    @vim_S    _         _         del
      _                                                         @vim_y      @vim_b    @vim_w    @vim_o    @vim_p    _         _
      _         _         _         @vim_d    _                 left        down      up        right     _
                                                                            @vim_^    @vim_$    S-down
    )

    (deflayer com
      _         _         _         _         _         _         _         _         _         _         _         _         _
                brdn      brup      mctl      @ar       bldn      blup      prev      pp        next      mute      vold      volu      del
      _                                                           _         _         _         _         -         _         @gmail
      caps      _         _         _         _                   _         _         _         _         _
                                                                            _         _         _
    )
  '';

  homeRowModsDarwin = mkHomeRowMods "darwin" "base";
  homeRowModsLinux = mkHomeRowMods "linux" "base";
  homeRowModsLinuxExt = mkHomeRowMods "linux" "extended";

  homeRowModsBin = pkgs.writeShellScriptBin "hrm" ''
    if tmux has-session -t 'home-row-mods' 2>/dev/null; then
      tmux kill-session -t 'home-row-mods'
    fi
    tmux new-session -d -s 'home-row-mods'
    if [[ "$1" = ext ]]; then
      tmux send-keys -t 'home-row-mods' "sudo kmonad $HOME/.config/kmonad/home_row_mods_ext.kbd" Enter
    else
      tmux send-keys -t 'home-row-mods' "sudo kmonad $HOME/.config/kmonad/home_row_mods.kbd" Enter
    fi
  '';

in lib.mkMerge [
  {
    home.packages = [ homeRowModsBin ];
  }
  (lib.mkIf isDarwin {
    xdg.configFile."kmonad/home_row_mods.kbd".text = homeRowModsDarwin;
  })
  (lib.mkIf isLinux {
    xdg.configFile."kmonad/home_row_mods.kbd".text = homeRowModsLinux;
    xdg.configFile."kmonad/home_row_mods_ext.kbd".text = homeRowModsLinuxExt;
    home.packages = [ pkgs.kmonad ];
  })
]
