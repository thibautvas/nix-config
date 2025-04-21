{ config, lib, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    silent = true;
    config.whitelist.prefix = [ config.home.sessionVariables.HOST_PROJECT_DIR ];
  };
}
