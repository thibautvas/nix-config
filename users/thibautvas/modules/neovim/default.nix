{
  config,
  lib,
  pkgs,
  unstablePkgs,
  flakes,
  ...
}:

{
  home.packages = [
    (import ./package.nix {
      inherit pkgs unstablePkgs;
      inherit (flakes) neovim-nightly-overlay gitutils-nvim;
    })
  ];
}
