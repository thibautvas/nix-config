{
  config,
  lib,
  pkgs,
  flakes,
  ...
}:

let
  primaryUser = "thibautvas";

in
{
  system.stateVersion = "24.11"; # should not be changed

  imports = [ flakes.nixos-wsl.nixosModules.wsl ];

  wsl = {
    enable = true;
    defaultUser = primaryUser;
  };
}
