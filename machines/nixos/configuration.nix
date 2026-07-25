{
  isHost,
  flakes,
  ...
}:

let
  primaryUser = "thibautvas";

  commonCfg = {
    system.stateVersion = "24.11";

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

    nixpkgs.flake = {
      setNixPath = false;
      setFlakeRegistry = false;
    };

    nix = {
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      registry = {
        nixpkgs.flake = flakes.nixpkgs-unstable;
        templates.flake = flakes.templates;
        tv.flake = flakes.self;
      };
    };
  };

  bootCfg = {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
  };

  hostCfg = bootCfg // {
    imports = [
      ./hardware/host-configuration.nix
      ./custom/thinkpad-leds.nix
      ./custom/libvirtd-hooks.nix
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
  };

  guestCfg = bootCfg // {
    imports = [ ./hardware/guest-configuration.nix ];

    services.openssh.enable = true;
  };

  wslCfg = {
    imports = [ flakes.nixos-wsl.nixosModules.wsl ];

    wsl = {
      enable = true;
      defaultUser = primaryUser;
    };
  };

in
commonCfg
// (
  if flakes ? nixos-wsl then
    wslCfg
  else if isHost then
    hostCfg
  else
    guestCfg
)
