{ config, lib, pkgs, isDesktop, isDarwin, isLinux, ... }:

let
  username = "thibautvas";
  homeDirectory = "${(if isDarwin then "/Users" else "/home")}/${username}";
  projectDirectory = "${homeDirectory}/repos";
  color = if isDarwin then "GREEN"
          else if isDesktop then "CYAN"
          else "MAGENTA";

in {
  imports = [
    ./modules/git.nix
    ./modules/lazygit.nix
    ./modules/shellrc.nix
    ./modules/direnv.nix
    ./modules/tmux
    ./modules/neovim
  ] ++ lib.optionals isDesktop [
    ./modules/ghostty.nix
    ./modules/firefox.nix
    ./modules/kmonad.nix
    ./modules/localbin.nix
  ] ++ lib.optionals isDarwin [
    ./modules/window-manager/aerospace
    ./modules/darwinapps.nix
    ./modules/vscode.nix
  ] ++ lib.optionals (isDesktop && isLinux) [
    ./modules/window-manager/hyprland
  ];

  home = {
    stateVersion = "24.11"; # should not be changed

    inherit username homeDirectory;

    sessionVariables = {
      HOST_PROJECT_DIR = projectDirectory;
      HOST_COLOR = color;
    };

    packages = with pkgs; [
      fzf
      fd
      ripgrep
    ];
  };

  programs.home-manager.enable = true; # let home manager manage itself
}
