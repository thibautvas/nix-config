{
  pkgs,
  dotfiles,
  ...
}:

{
  home.packages = [
    (import ./package.nix {
      inherit pkgs dotfiles;
      wrapGit = false;
    })
  ];
}
