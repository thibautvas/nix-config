{
  config,
  lib,
  pkgs,
  ...
}:

let
  homeDir = config.home.homeDirectory;

in
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
    config.whitelist.prefix = [
      "${homeDir}/repos"
      "${homeDir}/Music"
      "${homeDir}/Pictures"
    ];
  };
}
