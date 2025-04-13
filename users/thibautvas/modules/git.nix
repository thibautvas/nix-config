{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "thibautvas";
    userEmail = "thibaut.vas@gmail.com";
    extraConfig.init.defaultBranch = "main";
    ignores = [
      "temp.*"
      "temp/"
      "*.bak"
      ".direnv/"
      ".venv/"
      "*.egg-info/"
    ];
  };
}
