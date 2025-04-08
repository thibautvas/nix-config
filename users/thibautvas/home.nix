{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/direnv.nix
    ./modules/ghostty.nix
    ./modules/firefox.nix
    ./modules/kmonad.nix
    ./modules/neovim/main.nix
    ./modules/tmux/main.nix
    ./modules/window-manager/aerospace/main.nix
    ./modules/window-manager/hyprland/main.nix
  ];

  options = {
    aerospace.enable = lib.mkOption { default = pkgs.stdenv.isDarwin; };
    hyprland.enable = lib.mkOption { default = pkgs.stdenv.isLinux; };
  };

  config = {
    home = {
      stateVersion = "24.11"; # should not be changed

      username = "thibautvas";
      homeDirectory = "/home/thibautvas"; # linux standard

      packages = with pkgs; [
        tree
        fzf
        fd
        ripgrep
      ];

      sessionPath = [ "${config.home.homeDirectory}/.local/bin" ]; # prepend to path

      sessionVariables = {
        HOSTRD = "${config.home.homeDirectory}/repos";
        HOSTCOLOR = "CYAN";
      };
    };

    programs.home-manager.enable = true; # let home manager manage itself
  };
}
