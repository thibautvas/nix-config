{ config, lib, pkgs, ... }:

{
  imports = [
    ./settings.nix
    ./bin.nix
  ];

  programs.tmux.enable = true;
}
