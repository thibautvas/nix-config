{
  pkgs,
  lib,
  isHost,
  ...
}:

let
  username = "thibautvas";
  homeDirectory = "${(if pkgs.stdenv.isDarwin then "/Users" else "/home")}/${username}";

in
{
  imports = lib.optionals isHost [ ./modules/zen-twilight.nix ];

  home = {
    stateVersion = "24.11"; # should not be changed
    inherit username homeDirectory;
  };

  programs.home-manager.enable = true; # let home manager manage itself
}
