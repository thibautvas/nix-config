{
  pkgs,
  lib,
  isHost,
  flakes,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

in
{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    registry = {
      templates.flake = flakes.templates;
      tv.flake = flakes.self;
    };
  };

  imports = lib.optionals isHost [
    ../../users/thibautvas/modules/bash
    ../../users/thibautvas/modules/git.nix
    ../../users/thibautvas/modules/direnv.nix
  ];

  environment.systemPackages = lib.optionals isHost [ flakes.self.packages.${system}.imp ];
}
