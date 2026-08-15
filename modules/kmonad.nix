{
  self,
  pkgs,
  ...
}:

let
  kernel = pkgs.stdenv.hostPlatform.parsed.kernel.name;

  kbdId = "usb-Keychron_Keychron_V4-event-kbd";
  kbdTmpl = builtins.readFile (self + /dotfiles/kmonad.kbd.in);

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
        ext = "device-file \"/dev/input/by-id/${kbdId}\"";
      };
      output = "uinput-sink \"output\"";
      hypMet = "lmet";
      ctlMet = "C";
      altMet = {
        base = "alt";
        ext = "met";
      };
      altCtl = "C";
      start = "home";
      end = "end";
    };
  };

  perKernelKbd =
    kernel: kbd:
    let
      inherit (kbdCfg.${kernel})
        input
        output
        hypMet
        ctlMet
        altMet
        altCtl
        start
        end
        ;
      inputCfg = input.${kbd};
      thmMod = altMet.${kbd};
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

  hrmTxt = {
    darwin.base = pkgs.writeText "hrm_base.kbd" (perKernelKbd "darwin" "base");
    linux = {
      base = pkgs.writeText "hrm_base.kbd" (perKernelKbd "linux" "base");
      ext = pkgs.writeText "hrm_ext.kbd" (perKernelKbd "linux" "ext");
    };
  };

  hrmCmd = {
    darwin = "sudo -b kmonad ${hrmTxt.darwin.base}";
    linux = ''
      [[ -L /dev/input/by-id/${kbdId} ]] &&
        sudo -b kmonad ${hrmTxt.linux.ext}
      sudo -b kmonad ${hrmTxt.linux.base}
    '';
  };

  runtimeInputs = {
    darwin = [ ];
    linux = [ pkgs.kmonad ];
  };

in
pkgs.writeShellApplication {
  name = "hrm";
  runtimeInputs = runtimeInputs.${kernel};
  text = ''
    sudo pkill -x kmonad || true # kill previous process
    ${hrmCmd.${kernel}}
  '';
}
