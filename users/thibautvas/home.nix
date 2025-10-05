{ config, lib, pkgs, isHost, isDarwin, isLinux, ... }:

let
  username = "thibautvas";
  homeDirectory = "${(if isDarwin then "/Users" else "/home")}/${username}";
  workDir = "${homeDirectory}/repos";
  promptColor = if isDarwin then "green"
                else if isHost then "cyan"
                else "magenta";
  pickerCmd = "FzfLua files";

in {
  imports = [
    ./modules/nix.nix
    ./modules/git.nix
    ./modules/shellrc.nix
    ./modules/direnv.nix
    ./modules/pyproject.nix
    ./modules/tmux
    ./modules/neovim
  ] ++ lib.optionals isHost [
    ./modules/ghostty.nix
    ./modules/zen-twilight.nix
    ./modules/kmonad.nix
    ./modules/localbin.nix
  ] ++ lib.optionals isDarwin [
    ./modules/window-manager/aerospace
    ./modules/vscode.nix
  ] ++ lib.optionals (isHost && isLinux) [
    ./modules/window-manager/hyprland
  ];

  home = {
    stateVersion = "24.11"; # should not be changed

    inherit username homeDirectory;

    sessionVariables = {
      WORK_DIR = workDir;
      PROMPT_COLOR = promptColor;
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
