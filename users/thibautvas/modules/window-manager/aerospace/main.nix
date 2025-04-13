{ config, lib, pkgs, isDarwin, ... }:

{
  imports = [
    ./settings.nix
    ./bin.nix
  ];

  programs.aerospace = lib.mkIf isDarwin {
    enable = true;
  };
}
