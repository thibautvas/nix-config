{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    config.whitelist.prefix = [ "${config.home.sessionVariables.HOSTRD}" ];
  };
}
