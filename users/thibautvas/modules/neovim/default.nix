{
  config,
  lib,
  pkgs,
  flakes,
  ...
}:

let
  package = flakes.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

in
{
  # new imports are prepended to init.lua
  # settings.nix is always sourced last to put the mapleader at the top of init.lua
  imports = [
    ./kanagawa.nix
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
    inherit package;
    defaultEditor = true;
    vimdiffAlias = true;
  };
}
