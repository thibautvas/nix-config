{ config, lib, pkgs, isHost, ... }:

let
  role = if isHost then "host" else "guest";
  primaryUser = "thibautvas";

in {
  imports = [ ./hardware/${role}-configuration.nix ];

  system.stateVersion = "24.11"; # should not be changed

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  time.timeZone = "Europe/Madrid";

  users.users.${primaryUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
  };

  security.sudo.extraRules = [{
    users = [ primaryUser];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];
}

// lib.optionalAttrs isHost {
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
  services.openssh.enable = true;
}
