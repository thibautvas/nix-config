{ config, pkgs, ... }:

let
  statusSumUp = pkgs.writeShellScriptBin "sup" ''
    date +"%a %b %d %H:%M"
    if [[ $(uname) = 'Darwin' ]]; then
      pmset -g batt | grep -Eo '\d+%'
      ipconfig getsummary en0 | grep ' SSID : ' | cut -d':' -f2 | xargs
      system_profiler SPAudioDataType |
        awk '/Default Output Device: Yes/ {print prev2} {prev2=prev; prev=$0}' |
        cut -d':' -f1 |
        xargs
    elif [[ $(uname) = 'Linux' ]]; then
      echo "$(cat /sys/class/power_supply/BAT1/capacity)%"
      nmcli -g GENERAL.CONNECTION device show | head -n1
      bluetoothctl info | grep 'Name: ' | cut -d':' -f2 | xargs
    fi
  '';

  bluetoothConnect = pkgs.writeShellScriptBin "btc" ''
    if [[ "$1" = h* ]]; then
      MAC="98:47:44:93:A6:83"
    elif [[ "$1" = s* ]]; then
      MAC="40:72:18:EB:17:A7"
    fi

    if [[ $(uname) = 'Darwin' ]]; then
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title btc
      # @raycast.mode compact

      # Optional parameters:
      # @raycast.icon 🤖
      # @raycast.argument1 { "type": "text", "placeholder": "Placeholder" }

      # Documentation:
      # @raycast.author Thibaut Vas
      # @raycast.authorURL https://github.com/thibautvas

      blueutil --power 1
      blueutil --connect "$MAC"

    elif [[ $(uname) = 'Linux' ]]; then
      bluetoothctl connect "$MAC" && exit 0
      bluetoothctl pair "$MAC" && bluetoothctl connect "$MAC" && exit 0
    fi
  '';

in {
  home.packages = [
    statusSumUp
    bluetoothConnect
  ] ++ (if pkgs.stdenv.isDarwin then [ pkgs.blueutil ] else []);
}
