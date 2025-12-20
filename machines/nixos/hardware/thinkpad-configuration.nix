{
  config,
  lib,
  pkgs,
  ...
}:

let
  ledScript = pkgs.writeShellScript "kill_leds" ''
    for led in /sys/class/leds/tpacpi::power/brightness \
               /sys/class/leds/tpacpi::lid_logo_dot/brightness \
               /sys/class/leds/platform::mute/brightness \
               /sys/class/leds/platform::micmute/brightness
    do
      echo 0 > "$led"
    done
  '';

in
{
  systemd.services.ledsOnBoot = {
    description = "kill leds on boot and resume";
    wantedBy = [
      "multi-user.target"
      "sleep.target"
    ];
    after = [ "systemd-suspend.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ledScript;
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", \
    ATTR{online}=="1", \
    RUN+="/bin/sh -c 'sleep 3; ${ledScript}'"
  '';

  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth = false;
    sudo.fprintAuth = false;
  };
}
