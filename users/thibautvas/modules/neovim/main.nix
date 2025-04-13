{ config, lib, pkgs, ... }:

{
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
    defaultEditor = true;
    vimdiffAlias = true;
  };
}
