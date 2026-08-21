{
  machine,
  lib,
  ...
}:

let
  primaryUser = "thibautvas";

  perMachineImp =
    machine:
    [
      ../common/base.nix
      ../common/settings.nix
      ./hardware/${machine}-configuration.nix
    ]
    ++ lib.optionals (machine == "host") [
      ./custom/thinkpad-leds.nix
      ./custom/libvirtd-hooks.nix
    ];

in
{
  system.stateVersion = "24.11";

  imports = perMachineImp machine;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    tmp.cleanOnBoot = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  time.timeZone = "Europe/Madrid";

  users.users.${primaryUser} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "libvirtd"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ primaryUser ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}

// lib.optionalAttrs (machine == "host") {
  networking.networkmanager.enable = true;

  services = {
    graphical-desktop.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  virtualisation.libvirtd.enable = true;
}

// lib.optionalAttrs (machine == "guest") {
  services.openssh.enable = true;
}
