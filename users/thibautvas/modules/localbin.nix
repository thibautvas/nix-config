{ config, lib, pkgs, isDarwin, ... }:

let
  statusSumUp = pkgs.writeShellScriptBin "sup" ''
    date +"%a %b %d %H:%M"
    ${if isDarwin then ''
      # @raycast.schemaVersion 1
      # @raycast.title sup
      # @raycast.mode fullOutput
      pmset -g batt | grep -Eo '[0-9]+%'
      ipconfig getsummary en0 | awk -F ': ' '/ SSID : / {print $2}'
      system_profiler SPAudioDataType |
        awk '{buf[NR]=$0} /Default Output Device: Yes/ {print buf[NR-2]}' |
        sed -e 's/^ *//' -e 's/:$//'
    '' else ''
      echo "$(cat /sys/class/power_supply/BAT1/capacity)%"
      nmcli -g GENERAL.CONNECTION device show | head -n1
      bluetoothctl info | awk -F ': ' '/Name: / {print $2}'
    ''}
  '';

  bluetoothConnect = pkgs.writeShellScriptBin "btc" ''
    if [[ "$1" = h* ]]; then
      MAC="98:47:44:93:A6:83"
    elif [[ "$1" = s* ]]; then
      MAC="40:72:18:EB:17:A7"
    fi
    ${if isDarwin then ''
      # @raycast.schemaVersion 1
      # @raycast.title btc
      # @raycast.mode compact
      # @raycast.argument1 { "type": "text", "placeholder": "device" }
      blueutil --power 1
      blueutil --connect "$MAC"
    '' else ''
      bluetoothctl connect "$MAC" && exit 0
      (echo 'scan on'; sleep 3) | bluetoothctl &&
        bluetoothctl pair "$MAC" &&
        bluetoothctl connect "$MAC"
    ''}
  '';

in {
  home.packages = [
    statusSumUp
    bluetoothConnect
  ] ++ lib.optionals isDarwin [ pkgs.blueutil ];
}
