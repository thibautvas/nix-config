{ config, pkgs, ... }:

{
  home = {
    stateVersion = "24.11"; # should not be changed

    username = "thibautvas";
    homeDirectory = "/home/thibautvas"; # linux standard

    packages = with pkgs; [
      vim
      tmux
      tree
      fzf
      fd
      ripgrep
    ];

    sessionPath = [ "${config.home.homeDirectory}/.local/bin" ]; # prepend to path

    sessionVariables = {
      EDITOR = "vim";
      HOSTRD = "${config.home.homeDirectory}/repos";
      HOSTCOLOR = "cyan";
    };
  };

  programs.home-manager.enable = true; # let home manager manage itself

  imports = [
    ./modules/git.nix
    ./modules/shell.nix
    ./modules/ghostty.nix
    ./modules/firefox.nix
  ];
}
