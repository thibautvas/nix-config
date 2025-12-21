{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./settings.nix
    ./bin.nix
  ];

  programs.aerospace.enable = true;

  home.packages = [ pkgs.choose-gui ];
}
