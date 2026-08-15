{
  pkgs,
  env,
  ...
}:

let
  inherit (pkgs) lib;

  hyprRc = ../dotfiles/hyprland.lua;

  extraPkgs = with pkgs; [
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
pkgs.symlinkJoin {
  name = "hyprland-wrapped";
  paths = with pkgs; [
    hyprland
    hyprlock
    hypridle
  ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/Hyprland \
      --add-flags "-c ${hyprRc}" \
      --prefix PATH : ${lib.makeBinPath extraPkgs} \
      ${wrapperEnv}
    ln -s ../../../share/hypr/hypridle.conf $out/etc/xdg/hypr/hypridle.conf
  '';
}
