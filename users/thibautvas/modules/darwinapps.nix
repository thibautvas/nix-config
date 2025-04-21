{ config, lib, pkgs, unstablePkgs, isDarwin, ... }:

{
  home.packages = lib.optionals isDarwin (with unstablePkgs; [
    arc-browser
    raycast
    shortcat
  ]);
}
