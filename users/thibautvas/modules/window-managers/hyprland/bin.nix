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

  hyprctlLaunchAlt = pkgs.writeShellScriptBin "hyprctl-launch-alt" ''
    binary="$1"
    class="$2"
    workspace="$3"

    if ! hyprctl clients | grep -q "class: $class"; then
      hyprctl dispatch exec "$binary"
      sleep 1
    fi

    hyprctl dispatch movetoworkspace "$workspace", class:"$class"
    hyprctl dispatch layoutmsg swapwithmaster
  '';

in
{
  home.packages = [
    hyprctlLaunch
    hyprctlLaunchAlt
  ];
}
