{ config, lib, pkgs, isDesktop, isDarwin, isLinux, ... }:

let
  username = "thibautvas";
  homeDirectory = "${(if isDarwin then "/Users" else "/home")}/${username}";
  hostProjectDir = "${homeDirectory}/repos";
  hostColor = if isDarwin then "GREEN"
              else if isDesktop then "CYAN"
              else "MAGENTA";
  pickerCmd = "FzfLua files";

in {
  imports = [
    ./modules/git.nix
    ./modules/lazygit.nix
    ./modules/shellrc.nix
    ./modules/direnv.nix
    ./modules/pyproject.nix
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
      HOST_PROJECT_DIR = hostProjectDir;
      HOST_COLOR = hostColor;
      PICKER_CMD = pickerCmd;
    };

    packages = with pkgs; [
      fzf
      fd
      ripgrep
    ];
  };

  programs.home-manager.enable = true; # let home manager manage itself
}
