{ config, lib, pkgs, ... }:

let
  # lock nvim 0.11.1
  oldPkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/12a55407652e04dcf2309436eb06fef0d3713ef3.tar.gz";
    sha256 = "sha256-N4cp0asTsJCnRMFZ/k19V9akkxb7J/opG+K+jU57JGc=";
  }) {
    inherit (pkgs) system;
  };

in {
  # new imports are prepended to init.lua
  # settings.nix is always sourced last to put the mapleader at the top of init.lua
  imports = [
    ./catppuccin.nix
    ./gitsigns.nix
    ./telescope.nix
    ./treesitter.nix
    ./lspconfig.nix
    ./blink.nix
    ./settings.nix
  ];

  programs.neovim = {
    enable = true;
    package = oldPkgs.neovim-unwrapped;
    defaultEditor = true;
    vimdiffAlias = true;
  };
}
