{
  pkgs,
  ...
}:

let
  extraPkgs = with pkgs; [
    hyprshot
    wl-clipboard
    cliphist
    wofi
    brightnessctl
    playerctl
  ];

in
pkgs.symlinkJoin {
  name = "hyprland";
  paths = [ pkgs.hyprland ];
  nativeBuildInputs = [ pkgs.makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/Hyprland \
      --add-flags "--config ${./hyprland.lua}" \
      --prefix PATH : ${pkgs.lib.makeBinPath extraPkgs}
  '';
}
