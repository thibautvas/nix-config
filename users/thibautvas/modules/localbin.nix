{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  statusSumUp = pkgs.writeShellScriptBin "sup" ''
    date +"%a %b %d %H:%M"
    ${
      if isDarwin then
        ''
          pmset -g batt | grep -Eo '[0-9]+%'
          ipconfig getsummary en0 | awk -F ': ' '/ SSID : / {print $2}'
          system_profiler SPAudioDataType |
          awk '{buf[NR]=$0} /Default Output Device: Yes/ {print buf[NR-2]}' |
          sed -e 's/^ *//' -e 's/:$//'
        ''
      else
        ''
          echo "$(cat /sys/class/power_supply/BAT0/capacity)%"
          nmcli -g GENERAL.CONNECTION device show | head -n1
          bluetoothctl info | awk -F ': ' '/Name: / {print $2}'
        ''
    }
  '';

  bluetoothConnect = pkgs.writeShellApplication {
    name = "btc";
    runtimeInputs = lib.optionals isDarwin [ pkgs.blueutil ];
    text = ''
      if [[ "$1" = h* ]]; then
        MAC="98:47:44:93:A6:83"
      elif [[ "$1" = s* ]]; then
        MAC="40:72:18:EB:17:A7"
      fi
      ${
        if isDarwin then
          ''
            blueutil --power 1
            blueutil --connect "$MAC"
          ''
        else
          ''
            bluetoothctl connect "$MAC"
          ''
      }
    '';
  };

  # todo: darwin version
  wifiConnect = pkgs.writeShellApplication {
    name = "wfc";
    runtimeInputs = [ pkgs.fzf ];
    text = ''
      SSID=$(
        nmcli -g SSID device wifi list --rescan no |
        grep -v '^$' |
        fzf --reverse --height 10 --bind "ctrl-x:execute(sudo nmcli connection delete {})"
      )
      [[ -n "$SSID" ]] &&
      read -r PASSWORD &&
      sudo nmcli device wifi connect "$SSID" ''${PASSWORD:+password "$PASSWORD"}
    '';
  };

  # todo: darwin version
  processList = pkgs.writeShellApplication {
    name = "pls";
    runtimeInputs = [ pkgs.fzf ];
    text = ''
      ps -u "$USER" -o pid,cmd --sort=-lstart --no-headers |
      fzf --reverse --height 10 --bind "ctrl-x:execute(kill {1})+accept"
    '';
  };

  virshList = pkgs.writeShellApplication {
    name = "vls";
    runtimeInputs = [ pkgs.fzf ];
    text = ''
      sudo virsh list --all | sed '1,2d;$d' |
      fzf --reverse --height 10 --bind "ctrl-a:become(sudo virsh start {2})" \
                                --bind "ctrl-x:become(sudo virsh shutdown {2})" \
                                --bind "enter:become(TERM=xterm-256color ssh {2})"
    '';
  };

  runMp3 = pkgs.writeShellApplication {
    name = "run-mp3";
    runtimeInputs = with pkgs; [
      fzf
      (mpv.override (
        lib.optionalAttrs (!isDarwin) {
          scripts = [ mpvScripts.mpris ];
        }
      ))
    ];
    text = ''
      [[ -z "''${PICKER+x}" ]] && PICKER='fzf --reverse --height 7'
      dir="$HOME/Music"
      input_mp3="$(find "$dir" -type f -name '*.mp3' | sed "s:^$dir/::" | $PICKER)"
      pkill -x mpv || true
      mpv --no-video "$dir/$input_mp3" &
    '';
  };

in
{
  home.packages = [
    statusSumUp
    bluetoothConnect
    runMp3
  ]
  ++ lib.optionals (!isDarwin) [
    wifiConnect
    processList
    virshList
  ];
}
