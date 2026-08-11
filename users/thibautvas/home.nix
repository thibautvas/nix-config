{
  lib,
  isHost,
  isDarwin,
  ...
}:

let
  username = "thibautvas";
  homeDirectory = "${(if isDarwin then "/Users" else "/home")}/${username}";

in
{
  imports = [
    ./modules/git.nix
    ./modules/bash
    ./modules/direnv.nix
    ./modules/nvim
  ]
  ++ lib.optionals isHost [
    ./modules/ghostty.nix
    ./modules/zen-twilight.nix
    ./modules/kmonad.nix
    ./modules/localbin.nix
    ./modules/window-managers
  ];

  home = {
    stateVersion = "24.11"; # should not be changed
    inherit username homeDirectory;
  };

  programs.home-manager.enable = true; # let home manager manage itself
}
