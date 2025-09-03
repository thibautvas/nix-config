{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.nixos-wsl.nixosModules.wsl ];

  system.stateVersion = "24.11"; # should not be changed

  wsl.enable = true;
  wsl.defaultUser = "thibautvas";
}
