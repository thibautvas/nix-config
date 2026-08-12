{
  lib,
  isHost,
  ...
}:

let
  primaryUser = "thibautvas";

  commonImp = [
    ../common/base.nix
    ../common/settings.nix
  ];

in
{
  system.stateVersion = "24.11";

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
    initialPassword = "secret";
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

// lib.optionalAttrs isHost {
  imports = commonImp ++ [
    ./hardware/host-configuration.nix
    ./custom/thinkpad-leds.nix
    ./custom/libvirtd-hooks.nix
  ];

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

// lib.optionalAttrs (!isHost) {
  imports = commonImp ++ [ ./hardware/guest-configuration.nix ];

  services.openssh.enable = true;
}
