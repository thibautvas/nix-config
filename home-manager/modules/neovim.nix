{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  # new imports are prepended to init.lua
  # settings.nix is always sourced last to put the mapleader at the top of init.lua
  imports = [
    ./nvim-opts/catppuccin.nix
    ./nvim-opts/gitsigns.nix
    ./nvim-opts/telescope.nix
    ./nvim-opts/blink.nix
    ./nvim-opts/settings.nix
  ];
}
