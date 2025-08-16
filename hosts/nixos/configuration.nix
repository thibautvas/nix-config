{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "24.11"; # should not be changed
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/Madrid";

  networking.networkmanager.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  users.users.thibautvas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
  };

  security.sudo.extraRules = [{
    users = [ "thibautvas" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  programs = {
    hyprland.enable = true;
    hyprlock.enable = true;
  };

  virtualisation.libvirtd.enable = true;

  environment.systemPackages = [ pkgs.ntfs3g ];
}
