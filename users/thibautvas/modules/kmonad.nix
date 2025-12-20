{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  keychronKbd = "usb-Keychron_Keychron_V4-event-kbd";

  kbdCfg = {
    darwin = {
      input.base = "iokit-name";
      output = "kext";
      hypMet = "(around lmet (around lalt (around lctl lsft)))";
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

  mkHomeRowMods =
    osType: inputDevice:
    let
      inherit (kbdCfg.${osType})
        input
        output
        hypMet
        ctlMet
        altCtl
        start
        end
        ;
      inputCfg = input.${inputDevice};
    in
    ''
      (defcfg
        input (${inputCfg})
        output (${output})
        fallthrough true
        allow-cmd true
      )

      (defalias
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
        gmail #(t h i b a u t . v a s @ g m a i l . c o m)
      )

      (defsrc
        esc       f1        f2        f3        f4        f5        f6        f7        f8        f9        f10       f11       f12
                  1         2         3                   5         6         7         8         9         0         -         =         bspc
                                                                    y         u         i         o         p         [         ]
        caps      a         s         d         f                   h         j         k         l         ;         '
                                      c         v                             m         ,         .
      )

      (deflayer mod
        grv       brdn      brup      mctl      _         bldn      blup      prev      pp        next      mute      vold      volu
                  _         _         _                   _         _         _         _         _         _         _         _         _
                                                                    _         _         _         _         _         _         _
        @nav_esc  @alt_a    @hym_s    @sft_d    @ctl_f              _         @ctl_j    @sft_k    @met_l    @alt_;    _
                                      _         _                             _         _         _
      )

      (deflayer nav
        _         f1        f2        f3        f4        f5        f6        f7        f8        f9        f10       f11       f12
                  brdn      brup      mctl                bldn      blup      prev      pp        next      mute      vold      volu      del
                                                                    @vim_y    @vim_b    @vim_w    @vim_o    @vim_p    S-@vim_b  S-@vim_w
        _         _         @vim_S    @vim_d    _                   left      down      up        right     _         @gmail
                                      caps      @vim_V                        @vim_^    @vim_$    S-down
      )
    '';

  homeRowModsBin =
    let
      homeRowMods =
        if isDarwin then
          {
            base = pkgs.writeText "home_row_mods.kbd" (mkHomeRowMods "darwin" "base");
          }
        else
          {
            base = pkgs.writeText "home_row_mods.kbd" (mkHomeRowMods "linux" "base");
            extended = pkgs.writeText "home_row_mods_ext.kbd" (mkHomeRowMods "linux" "extended");
          };
    in
    pkgs.writeShellApplication {
      name = "hrm";
      runtimeInputs = lib.optionals (!isDarwin) [ pkgs.kmonad ];
      text = ''
        sudo pkill -f "home_row_mods"
        ${
          if (!isDarwin) then
            ''
              [[ -L /dev/input/by-id/${keychronKbd} ]] &&
              sudo -b kmonad ${homeRowMods.extended}
            ''
          else
            ""
        }
        sudo -b kmonad ${homeRowMods.base}
      '';
    };

in
{
  home.packages = [ homeRowModsBin ];
}
