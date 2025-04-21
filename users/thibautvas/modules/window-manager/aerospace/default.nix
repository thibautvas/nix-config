{ config, lib, pkgs, ... }:

{
  imports = [
    ./settings.nix
    ./bin.nix
  ];

  programs.aerospace.enable = true;
}
