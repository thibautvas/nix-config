{ config, pkgs, lib, ... }:

{
  imports = [
    ./settings.nix
    ./bin.nix
  ];

  config = lib.mkIf config.aerospace.enable {
    programs.aerospace.enable = true;
  };
}
