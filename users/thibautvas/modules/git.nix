{ config, lib, pkgs, ... }:

let
  editor = config.home.sessionVariables.EDITOR or "vim";
  diffEditor = "${editor}diff";

in {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "thibautvas";
        email = "thibaut.vas@gmail.com";
      };
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
