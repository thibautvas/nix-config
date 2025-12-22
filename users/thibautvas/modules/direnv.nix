{
  config,
  lib,
  pkgs,
  ...
}:

let
  workDir = config.home.sessionVariables.WORK_DIR;
  homeDir = config.home.homeDirectory;

in
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
    config.whitelist.prefix = [
      workDir
      "${homeDir}/Music"
      "${homeDir}/Pictures"
    ];
  };
}
