{ config, pkgs, ... }:

{
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

  imports = [
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/direnv.nix
    ./modules/tmux.nix
    ./modules/neovim.nix
    ./modules/ghostty.nix
    ./modules/firefox.nix
    ./modules/hyprland.nix
  ];
}
