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
  symlinkJoin,
  makeWrapper,
  ...
}:

let
  kanshiCfgPath = writeText "config.kanshi" ''
    profile docked {
      output eDP-1 mode 1920x1200 position 0,0 scale 1.5
      output DP-2 mode 3840x2160 position 1280,0 scale 2
    }
    profile laptop {
      output eDP-1 mode 1920x1200 position 0,0 scale 1.5
    }
  '';

  kanshiWrapped = symlinkJoin {
    name = "kanshi-wrapped";
    paths = [ kanshi ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/kanshi \
        --add-flags "-c ${kanshiCfgPath}"
    '';
  };

  hypridleCfgPath = runCommand "hypridle.conf" { } ''
    substitute ${hypridle}/share/hypr/hypridle.conf $out \
      --replace-fail "hyprctl dispatch dpms off" "wlopm --off '*'" \
      --replace-fail "hyprctl dispatch dpms on" "wlopm --on '*'"
  '';

  hypridleWrapped = symlinkJoin {
    name = "hypridle-wrapped";
    paths = [ hypridle ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/hypridle \
        --add-flags "-c ${hypridleCfgPath}"
    '';
  };

  extraPkgs = [
    kanshiWrapped
    hypridleWrapped
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
      --prefix PATH : ${lib.makeBinPath extraPkgs} \
      --set XKB_DEFAULT_LAYOUT us \
      --set XKB_DEFAULT_VARIANT mac
  '';
}
