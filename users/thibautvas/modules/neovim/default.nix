{
  config,
  lib,
  pkgs,
  flakes,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

in
{
  # new imports are prepended to init.lua
  # settings.nix is always sourced last to put the mapleader at the top of init.lua
  imports = [
    ./catppuccin.nix
    ./gitutils.nix
    ./gitsigns.nix
    ./oil.nix
    ./fzf-lua.nix
    ./treesitter.nix
    ./lsp.nix
    ./blink.nix
    ./settings.nix
  ];

  programs.neovim = {
    enable = true;
    package = flakes.neovim-nightly-overlay.packages.${system}.default;
    defaultEditor = true;
    vimdiffAlias = true;
  };
}
