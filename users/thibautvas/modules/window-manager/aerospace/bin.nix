{
  config,
  lib,
  pkgs,
  ...
}:

let
  aerospaceMoveApp = pkgs.writeShellScriptBin "aerospace-move-app" ''
    open -a "$1" &&
    aerospace move-node-to-workspace --focus-follows-window "$2" &&
    aerospace move left
  '';

  aerospaceLaunchCode = pkgs.writeShellScriptBin "aerospace-lauch-code" ''
    aerospace list-windows --all | grep -q 'Code' &&
    open -a 'Visual Studio Code' ||
    open -a 'Visual Studio Code' "$1"
  '';

  aerospaceRestart = pkgs.writeShellScriptBin "aerospace-restart" ''
    killall AeroSpace
    open -a 'AeroSpace'
  '';

in
{
  home.packages = [
    aerospaceMoveApp
    aerospaceLaunchCode
    aerospaceRestart
  ];
}
