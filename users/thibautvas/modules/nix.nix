{
  config,
  lib,
  pkgs,
  flakes,
  ...
}:

{
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    registry = {
      nixpkgs.flake = flakes.nixpkgs-unstable;
      templates.flake = flakes.templates;
    };
  };
}
