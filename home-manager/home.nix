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

    sessionVariables.EDITOR = "vim";
  };

  programs = {
    home-manager.enable = true; # let home manager manage itself
    firefox.enable = true;
    ghostty.enable = true;
    zsh.enable = true;

    git = {
      enable = true;
      userName = "thibautvas";
      userEmail = "thibaut.vas@gmail.com";
      extraConfig.init.defaultBranch = "main";
      ignores = [
        "temp.*"
        "temp/"
        "*.bak"
        ".venv/"
        "*.egg-info/"
      ];
    };
  };
}
