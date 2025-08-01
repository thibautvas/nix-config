{ config, lib, pkgs, isDarwin, isLinux, ... }:

let
  keychronKbd = "usb-Keychron_Keychron_V4-event-kbd";

  kbdCfg = {
    darwin = {
      input.base = "iokit-name";
      output = "kext";
      hypMet = "@hyp";
      ctlMet = "M";
      altCtl = "A";
      start = "M-left";
      end = "M-right";
    };
    linux = {
      input = {
        base = "device-file \"/dev/input/by-path/platform-i8042-serio-0-event-kbd\"";
        extended = "device-file \"/dev/input/by-id/${keychronKbd}\"";
      };
      output = "uinput-sink \"output\"";
      hypMet = "lmet";
      ctlMet = "C";
      altCtl = "C";
      start = "home";
      end = "end";
    };
  };

  mkHomeRowMods = osType: inputDevice: let
    inherit (kbdCfg.${osType}) input output hypMet ctlMet altCtl start end;
    inputCfg = input.${inputDevice};
  in ''
    (defcfg
      input (${inputCfg})
      output (${output})
      fallthrough true
      allow-cmd true
    )

    (defalias
      ;; hyper
      hyp (around rmet (around ralt (around rctl rsft)))

      ;; home row mods (AMSC)
      alt_a (tap-hold-next-release 200 a lalt)
      hym_s (tap-hold-next-release 200 s ${hypMet})
      sft_d (tap-hold-next-release 200 d lsft)
      ctl_f (tap-hold-next-release 200 f lctl)
      ctl_j (tap-hold-next-release 200 j rctl)
      sft_k (tap-hold-next-release 200 k rsft)
      met_l (tap-hold-next-release 200 l rmet)
      alt_; (tap-hold-next-release 200 ; ralt)

      ;; navigation layer
      nav (layer-toggle nav)
      nav_esc (tap-hold-next-release 200 esc @nav)
      vim_d #(${ctlMet}-x)
      vim_y #(${ctlMet}-c)
      vim_p #(${ctlMet}-v)
      vim_b #(${altCtl}-left)
      vim_w #(${altCtl}-right)
      vim_^ ${start}
      vim_$ ${end}
      vim_V #(${start} S-${end})
      vim_S #(${end} S-${start} bspc)
      vim_o #(${end} S-ret)

      ;; comfort layer: email addresses and accessible controls for 60% keyboard
      com (layer-toggle com)
      com_tab (tap-hold-next-release 200 tab @com)
      gmail #(t h i b a u t . v a s @ g m a i l . c o m)
    )

    (defsrc
      esc       f1        f2        f3        f4        f5        f6        f7        f8        f9        f10       f11       f12
                1         2         3         4         5         6         7         8         9         0         -         =         bspc
      tab                                                         y         u         i         o         p         [         ]
      caps      a         s         d         f                   h         j         k         l         ;
                                                                            m         ,         .
    )

    (deflayer mod
      grv       brdn      brup      mctl      _         bldn      blup      prev      pp        next      mute      vold      volu
                _         _         _         _         _         _         _         _         _         _         _         _         _
      @com_tab                                                    _         _         _         _         _         _         _
      @nav_esc  @alt_a    @hym_s    @sft_d    @ctl_f              _         @ctl_j    @sft_k    @met_l    @alt_;
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
                brdn      brup      mctl      _         bldn      blup      prev      pp        next      mute      vold      volu      del
      _                                                           _         _         _         _         -         _         @gmail
      caps      _         _         _         _                   _         _         _         _         _
                                                                            _         _         _
    )
  '';

  homeRowMods = {
    darwin = mkHomeRowMods "darwin" "base";
    linux = mkHomeRowMods "linux" "base";
    linuxExt = mkHomeRowMods "linux" "extended";
  };

  homeRowModsBin = pkgs.writeShellScriptBin "hrm" ''
    if tmux has-session -t 'home-row-mods' 2>/dev/null; then
      tmux kill-session -t 'home-row-mods'
    fi
    if [[ -L /dev/input/by-id/${keychronKbd} ]]; then
      tmux new-session -d -s 'home-row-mods' 'sudo kmonad $HOME/.config/kmonad/home_row_mods_ext.kbd'
    else
      tmux new-session -d -s 'home-row-mods' 'sudo kmonad $HOME/.config/kmonad/home_row_mods.kbd'
    fi
  '';

in lib.mkMerge [
  {
    home.packages = [ homeRowModsBin ];
  }
  (lib.mkIf isDarwin {
    xdg.configFile."kmonad/home_row_mods.kbd".text = homeRowMods.darwin;
  })
  (lib.mkIf isLinux {
    xdg.configFile."kmonad/home_row_mods.kbd".text = homeRowMods.linux;
    xdg.configFile."kmonad/home_row_mods_ext.kbd".text = homeRowMods.linuxExt;
    home.packages = [ pkgs.kmonad ];
  })
]
