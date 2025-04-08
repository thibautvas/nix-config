{ config, pkgs, lib, ... }:

let
  aerospaceMoveApp = pkgs.writeShellScriptBin "aerospace-move-app" ''
    open -a "$1" &&
    aerospace move-node-to-workspace --focus-follows-window "$2" &&
    aerospace move left
  '';

  aerospaceRestart = pkgs.writeShellScriptBin "aerospace-restart" ''
    killall AeroSpace
    open /Applications/AeroSpace.app
  '';

in {
  config = lib.mkIf config.aerospace.enable {
    home.packages = [
      aerospaceMoveApp
      aerospaceRestart
    ];
  };
}
