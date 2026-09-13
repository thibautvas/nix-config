{
  lib,
  stdenv,
  blueutil,
  fzf,
  mpv,
  mpvScripts,
  writeShellApplication,
  writeShellScriptBin,
  symlinkJoin,
  ...
}:

let
  kernel = stdenv.hostPlatform.parsed.kernel.name;

  localApps = {
    statusSumUp = {
      darwin = writeShellScriptBin "sup" ''
        date +"%a %b %d %H:%M"
        pmset -g batt | grep -Eo '[0-9]+%'
        ipconfig getsummary en0 | awk -F ': ' '/ SSID : / {print $2}'
        system_profiler SPAudioDataType |
          awk '{buf[NR]=$0} /Default Output Device: Yes/ {print buf[NR-2]}' |
          sed -e 's/^ *//' -e 's/:$//'
      '';
      linux = writeShellScriptBin "sup" ''
        date +"%a %b %d %H:%M"
        echo "$(cat /sys/class/power_supply/BAT0/capacity)%"
        nmcli -g GENERAL.CONNECTION device show | head -n1
        bluetoothctl info | awk -F ': ' '/Name: / {print $2}'
      '';
    };

    bluetoothConnect =
      let
        shellApp =
          runtimeInputs: connect:
          writeShellApplication {
            name = "btc";
            inherit runtimeInputs;
            text = ''
              case "$1" in
                h*) MAC="98:47:44:93:A6:83" ;;
                s*) MAC="40:72:18:EB:17:A7" ;;
              esac
              ${connect}
            '';
          };
      in
      {
        darwin = shellApp [ blueutil ] ''
          blueutil --power 1
          blueutil --connect "$MAC"
        '';
        linux = shellApp [ ] ''
          bluetoothctl connect "$MAC"
        '';
      };

    # todo: darwin version
    wifiConnect.linux = writeShellApplication {
      name = "wfc";
      runtimeInputs = [ fzf ];
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
    processList.linux = writeShellApplication {
      name = "pls";
      runtimeInputs = [ fzf ];
      text = ''
        ps -u "$USER" -o pid,cmd --sort=-lstart --no-headers |
          fzf --reverse --height 10 --bind "ctrl-x:execute(kill {1})+accept"
      '';
    };

    virshList.linux = writeShellApplication {
      name = "vls";
      runtimeInputs = [ fzf ];
      text = ''
        addr() {
          virsh --connect qemu:///system --quiet domifaddr "$1" |
            awk '/ipv4/{print $4}' | cut -d/ -f1
        }
        export -f addr

        virsh --connect qemu:///system --quiet list --all |
          fzf --reverse --height 10 --bind "ctrl-a:become(sudo virsh start {2})" \
                                    --bind "ctrl-x:become(sudo virsh shutdown {2})" \
                                    --bind "enter:become(TERM=xterm-256color ssh \$(addr {2}))" \
                                    --bind "ctrl-r:become(TERM=xterm-256color ssh root@\$(addr {2}))"
      '';
    };

    runMp3 =
      let
        shellApp =
          new:
          writeShellApplication {
            name = "run-mp3";
            runtimeInputs = [
              fzf
              (mpv.override new)
            ];
            text = ''
              [[ -z "''${PICKER+x}" ]] && PICKER='fzf --reverse --height 7'
              dir="$HOME/Music"
              input_mp3="$(find "$dir" -type f -name '*.mp3' | sed "s:^$dir/::" | $PICKER)"
              pkill -x mpv || true
              mpv --no-video "$dir/$input_mp3"
            '';
          };
      in
      {
        darwin = shellApp { };
        linux = shellApp {
          scripts = [ mpvScripts.mpris ];
        };
      };
  };

in
symlinkJoin rec {
  name = "localbin-wrapped";
  paths = builtins.filter (x: x != null) (
    lib.mapAttrsToList (_: app: app.${kernel} or null) localApps
  );
  passthru.binaries = map (drv: drv.pname or drv.name) paths;
}
