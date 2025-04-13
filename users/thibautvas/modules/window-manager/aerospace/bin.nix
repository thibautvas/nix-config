{ config, lib, pkgs, isDarwin, ... }:

let
  aerospaceMoveApp = pkgs.writeShellScriptBin "aerospace-move-app" ''
    open -a "$1" &&
    aerospace move-node-to-workspace --focus-follows-window "$2" &&
    aerospace move left
  '';

  aerospaceRestart = pkgs.writeShellScriptBin "aerospace-restart" ''
    killall AeroSpace
    open -a 'AeroSpace'
  '';

in {
  home.packages = lib.optionals isDarwin [
    aerospaceMoveApp
    aerospaceRestart
  ];
}
