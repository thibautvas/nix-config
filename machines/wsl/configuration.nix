{ config, lib, pkgs, inputs, ... }:

let
  primaryUser = "thibautvas";

in {
  system.stateVersion = "24.11"; # should not be changed

  imports = [ inputs.nixos-wsl.nixosModules.wsl ];

  wsl = {
    enable = true;
    defaultUser = primaryUser;
  };
}
