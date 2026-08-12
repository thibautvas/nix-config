{
  pkgs,
  ...
}:

let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv) isDarwin;

  kbdId = "usb-Keychron_Keychron_V4-event-kbd";
  kbdTmpl = builtins.readFile ./ext/kmonad_hrm.kbd.in;

  kbdCfg = {
    darwin = {
      input.base = "iokit-name";
      output = "kext";
      hypMet = "(around lmet (around lalt (around lctl lsft)))";
      ctlMet = "M";
      altMet.base = "met";
      altCtl = "A";
      start = "M-left";
      end = "M-right";
    };
    linux = {
      input = {
        base = "device-file \"/dev/input/by-path/platform-i8042-serio-0-event-kbd\"";
        extended = "device-file \"/dev/input/by-id/${kbdId}\"";
      };
      output = "uinput-sink \"output\"";
      hypMet = "lmet";
      ctlMet = "C";
      altMet = {
        base = "alt";
        extended = "met";
      };
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
        altMet
        altCtl
        start
        end
        ;
      inputCfg = input.${inputDevice};
      thmMod = altMet.${inputDevice};
    in
    builtins.replaceStrings
      [
        "@INPUT@"
        "@OUTPUT@"
        "@HYP_MET@"
        "@CTL_MET@"
        "@ALT_CTL@"
        "@START@"
        "@END@"
        "@THM_MOD@"
      ]
      [
        inputCfg
        output
        hypMet
        ctlMet
        altCtl
        start
        end
        thmMod
      ]
      kbdTmpl;

  homeRowMods = lib.genAttrs [ "linux" "darwin" ] (
    osType:
    {
      base = pkgs.writeText "home_row_mods.kbd" (mkHomeRowMods osType "base");
    }
    // lib.optionalAttrs (osType == "linux") {
      extended = pkgs.writeText "home_row_mods_ext.kbd" (mkHomeRowMods osType "extended");
    }
  );

in
pkgs.writeShellApplication {
  name = "hrm";
  runtimeInputs = lib.optionals (!isDarwin) [ pkgs.kmonad ];
  text = ''
    sudo pkill -f "home_row_mods"
    ${
      if (!isDarwin) then
        ''
          [[ -L /dev/input/by-id/${kbdId} ]] &&
          sudo -b kmonad ${homeRowMods.linux.extended}
        ''
      else
        ""
    }
    sudo -b kmonad ${homeRowMods.${if isDarwin then "darwin" else "linux"}.base}
  '';
}
