{
  lib,
  river,
  ebro,
  kanshi,
  hypridle,
  hyprlock,
  wlopm,
  wlsunset,
  cliphist,
  wl-clipboard,
  wofi,
  grim,
  slurp,
  brightnessctl,
  playerctl,
  runCommand,
  writeText,
  writeShellScriptBin,
  symlinkJoin,
  makeWrapper,
  ...
}:

let
  kanshiCfg = writeText "kanshi.conf" ''
    profile docked {
      output DP-2 mode 3840x2160 position 0,0 scale 2
      output eDP-1 disable
    }
    profile docked-dual {
      output DP-2 mode 3840x2160 position 0,0 scale 2
      output eDP-1 enable mode 1920x1200 position 1920,0 scale 1.5
    }
    profile laptop {
      output eDP-1 enable mode 1920x1200 position 0,0 scale 1.5
    }
    profile laptop-off {
      output eDP-1 disable
    }
  '';

  kanshiToggle = writeShellScriptBin "kanshi-toggle" ''
    case "$(kanshictl status)" in
      *'"docked"'*) next=docked-dual ;;
      *'"docked-dual"'*) next=docked ;;
      *'"laptop"'*) next=laptop-off ;;
      *'"laptop-off"'*) next=laptop ;;
      *) exit 1 ;;
    esac
    exec kanshictl switch "$next"
  '';

  dpmsToWlopm =
    action:
    lib.escapeShellArgs [
      "--replace-fail"
      "hyprctl dispatch 'hl.dsp.dpms({action = \"${action}\"})'"
      "wlopm --${action} '*'"
    ];

  hypridleCfg = runCommand "hypridle.conf" { } ''
    substitute ${hypridle}/share/hypr/hypridle.conf $out \
      ${dpmsToWlopm "on"} \
      ${dpmsToWlopm "off"}
  '';

  extraPkgs = symlinkJoin {
    name = "extra-pkgs";
    paths = [
      kanshi
      kanshiToggle
      hypridle
      hyprlock
      wlopm
      wlsunset
      cliphist
      wl-clipboard
      wofi
      grim
      slurp
      brightnessctl
      playerctl
    ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/kanshi \
        --add-flags "-c ${kanshiCfg}"
      wrapProgram $out/bin/hypridle \
        --add-flags "-c ${hypridleCfg}"
      wrapProgram $out/bin/hyprlock \
        --add-flags "-c ${hyprlock}/share/hypr/hyprlock.conf"
    '';
  };

in
symlinkJoin {
  name = "river-wrapped";
  paths = [
    river
    ebro
  ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/river \
      --add-flags "-c ${lib.getExe ebro}" \
      --prefix PATH : ${extraPkgs}/bin \
      --set XKB_DEFAULT_LAYOUT us \
      --set XKB_DEFAULT_VARIANT mac
  '';
}
