{ config, lib, pkgs, ... }:

let
  editor = config.home.sessionVariables.EDITOR or "vim";
  diffEditor = "${editor}diff";

in {
  programs.git = {
    enable = true;
    userName = "thibautvas";
    userEmail = "thibaut.vas@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      diff.tool = diffEditor;
      difftool.prompt = false;
    };
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
