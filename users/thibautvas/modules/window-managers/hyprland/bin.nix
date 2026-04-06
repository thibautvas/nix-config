{
  config,
  lib,
  pkgs,
  ...
}:

let
  hyprctlLaunch = pkgs.writeShellScriptBin "hyprctl-launch" ''
    binary="$1"
    class="$2"

    if hyprctl clients | grep -q "class: $class"; then
      hyprctl dispatch focuswindow class:"$class"
    else
      hyprctl dispatch exec "$binary"
    fi
  '';

  hyprctlMove = pkgs.writeShellScriptBin "hyprctl-move" ''
    class="$1"
    workspace="$2"

    hyprctl dispatch movetoworkspace "$workspace", class:"$class"
  '';

in
{
  home.packages = [
    hyprctlLaunch
    hyprctlMove
  ];
}
