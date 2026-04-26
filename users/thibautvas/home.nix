{
  config,
  lib,
  pkgs,
  unstablePkgs,
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
    ./modules/nix.nix
    ./modules/git.nix
    ./modules/bash
    ./modules/direnv.nix
    ./modules/neovim
  ]
  ++ lib.optionals isHost [
    ./modules/emacs.nix
    ./modules/ghostty.nix
    ./modules/zen-twilight.nix
    ./modules/kmonad.nix
    ./modules/localbin.nix
    ./modules/window-managers
  ]
  ++ lib.optionals isDarwin [
    ./modules/vscode.nix
  ];

  home = {
    stateVersion = "24.11"; # should not be changed

    inherit username homeDirectory;

    packages = [ unstablePkgs.claude-code ];
  };

  programs.home-manager.enable = true; # let home manager manage itself
}
