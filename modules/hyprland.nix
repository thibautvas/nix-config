{
  self,
  lib,
  env,
  hypridle,
  hyprland,
  hyprlock,
  hyprshot,
  hyprsunset,
  brightnessctl,
  playerctl,
  cliphist,
  wl-clipboard,
  wofi,
  symlinkJoin,
  makeWrapper,
  ...
}:

let
  hyprRc = self + /dotfiles/hyprland.lua;

  extraPkgs = [
    hyprshot
    hyprsunset
    wl-clipboard
    cliphist
    wofi
    brightnessctl
    playerctl
  ];

  wrapperEnv = lib.concatMapAttrsStringSep " " (
    name: value: "--set ${lib.toUpper name} ${toString value}"
  ) env;

in
symlinkJoin {
  name = "hyprland-wrapped";
  paths = [
    hyprland
    hyprlock
    hypridle
  ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/Hyprland \
      --add-flags "-c ${hyprRc}" \
      --prefix PATH : ${lib.makeBinPath extraPkgs} \
      ${wrapperEnv}
    ln -s $out/share/hypr/hypridle.conf $out/etc/xdg/hypr/hypridle.conf
  '';
}
