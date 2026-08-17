{
  self,
  pkgs,
  ...
}:

let
  inherit (pkgs) lib;
  kernel = pkgs.stdenv.hostPlatform.parsed.kernel.name;

  kbdId = "usb-Keychron_Keychron_V4-event-kbd";
  kbdTmpl = builtins.readFile (self + /dotfiles/kmonad.kbd.in);

  kbdCfg = {
    darwin = {
      base = {
        input = "iokit-name";
        output = "kext";
        hypMet = "(around lmet (around lalt (around lctl lsft)))";
        ctlMet = "M";
        altCtl = "A";
        start = "M-left";
        end = "M-right";
        thmMod = "met";
      };
    };
    linux = lib.genAttrs [ "base" "ext" ] (
      kbd:
      {
        output = "uinput-sink \"output\"";
        hypMet = "lmet";
        ctlMet = "C";
        altCtl = "C";
        start = "home";
        end = "end";
      }
      // lib.optionalAttrs (kbd == "base") {
        input = "device-file \"/dev/input/by-path/platform-i8042-serio-0-event-kbd\"";
        thmMod = "alt";
      }
      // lib.optionalAttrs (kbd == "ext") {
        input = "device-file \"/dev/input/by-id/${kbdId}\"";
        thmMod = "met";
      }
    );
  };

  perKernelKbd =
    kernel: kbd:
    let
      cfg = kbdCfg.${kernel}.${kbd};
      fmtKbd =
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
          (map (name: cfg.${name}) [
            "input"
            "output"
            "hypMet"
            "ctlMet"
            "altCtl"
            "start"
            "end"
            "thmMod"
          ])
          kbdTmpl;
    in
    pkgs.writeText "hrm-${kernel}-${kbd}.kbd" fmtKbd;

in
pkgs.writeShellApplication {
  name = "hrm";
  runtimeInputs = lib.optionals (kernel == "linux") [ pkgs.kmonad ];
  text = ''
    sudo pkill -x kmonad || true
    sudo -b kmonad ${perKernelKbd kernel "base"}
  ''
  + lib.optionalString (kernel == "linux") ''
    sudo -b kmonad ${perKernelKbd kernel "ext"} 2>/dev/null
  '';
}
