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
  kanshiCfg = writeText "kanshi.conf" ''
    profile docked {
      output eDP-1 mode 1920x1200 position 0,0 scale 1.5
      output DP-2 mode 3840x2160 position 1280,0 scale 2
    }
    profile laptop {
      output eDP-1 mode 1920x1200 position 0,0 scale 1.5
    }
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
