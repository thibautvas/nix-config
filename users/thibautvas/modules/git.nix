{
  config,
  lib,
  pkgs,
  flakes,
  ...
}:

{
  programs.git = {
    enable = true;
    includes = [
      {
        path = "${flakes.dotfiles}/git/config";
      }
    ];
    ignores = lib.splitString "\n" (builtins.readFile "${flakes.dotfiles}/git/ignore");
  };
}
