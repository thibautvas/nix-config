{
  pkgs,
  unstablePkgs,
  dotfiles,
  ...
}:

{
  home.packages = [
    (import ./package.nix {
      inherit pkgs unstablePkgs dotfiles;
    })
  ];
}
