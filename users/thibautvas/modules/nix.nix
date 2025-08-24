{ config, lib, pkgs, inputs, ... }:

{
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
    registry.nixpkgs.flake = inputs.nixpkgs-unstable;
  };
}
