{ config, lib, pkgs, unstablePkgs, ... }:

{
  home.packages = with unstablePkgs; [
    arc-browser
    raycast
    shortcat
  ];
}
