{
  self,
  ...
}:

let
  kbdTmpl = builtins.readFile (self + /dotfiles/kmonad.kbd.in);

  mkKbd =
    { device, thmMod }:
    {
      inherit device;
      config =
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
            "device-file \"${device}\""
            "uinput-sink \"output\""
            "lmet"
            "C"
            "C"
            "home"
            "end"
            thmMod
          ]
          kbdTmpl;
    };

in
{
  services.kmonad = {
    enable = true;
    keyboards = {
      base = mkKbd {
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        thmMod = "alt";
      };
      ext = mkKbd {
        device = "/dev/input/by-id/usb-Keychron_Keychron_V4-event-kbd";
        thmMod = "met";
      };
    };
  };
}
