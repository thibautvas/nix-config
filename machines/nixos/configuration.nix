{
  config,
  lib,
  pkgs,
  isHost,
  ...
}:

let
  primaryUser = "thibautvas";

in
{
  system.stateVersion = "24.11"; # should not be changed

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
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

// lib.optionalAttrs isHost {
  imports = [
    ./hardware/host-configuration.nix
    ./hardware/thinkpad-leds.nix
  ];

  networking.networkmanager.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  programs = {
    hyprland.enable = true;
    hyprlock.enable = true;
  };

  virtualisation.libvirtd.enable = true;
}

// lib.optionalAttrs (!isHost) {
  imports = [ ./hardware/guest-configuration.nix ];

  services.openssh.enable = true;
}
