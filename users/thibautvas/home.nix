{ config, lib, pkgs, isDarwin, ... }:

let
  username = "thibautvas";
  homeDirectory = "${(if isDarwin then "/Users" else "/home")}/${username}";
  projectDirectory = "${homeDirectory}/repos";
  color = if isDarwin then "GREEN" else "CYAN";

in {
  imports = [
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/direnv.nix
    ./modules/ghostty.nix
    ./modules/firefox.nix
    ./modules/kmonad.nix
    ./modules/localbin.nix
    ./modules/neovim/main.nix
    ./modules/tmux/main.nix
    ./modules/window-manager/aerospace/main.nix
    ./modules/window-manager/hyprland/main.nix
  ];

  home = {
    stateVersion = "24.11"; # should not be changed

    username = username;
    homeDirectory = homeDirectory;

    sessionVariables = {
      HOST_PROJECT_DIR = projectDirectory;
      HOST_COLOR = color;
    };

    packages = with pkgs; [
      tree
      fzf
      fd
      ripgrep
      lazygit
    ];
  };

  programs.home-manager.enable = true; # let home manager manage itself
}
