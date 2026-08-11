{
  isHost,
  flakes,
  ...
}:

let
  primaryUser = "thibautvas";

  commonImp = [ ../common/packages.nix ];

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
  };

  bootCfg.boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    tmp.cleanOnBoot = true;
  };

  hostCfg = bootCfg // {
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
  };

  guestCfg = bootCfg // {
    imports = commonImp ++ [ ./hardware/guest-configuration.nix ];

    services.openssh.enable = true;
  };

  wslCfg = {
    imports = commonImp ++ [ flakes.nixos-wsl.nixosModules.wsl ];

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
