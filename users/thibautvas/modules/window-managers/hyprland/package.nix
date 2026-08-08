{
  pkgs,
  defaultBins,
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
      --set BROWSER ${defaultBins.browser} \
      --set TERMINAL ${defaultBins.terminal} \
      --add-flags "--config ${./hyprland.lua}" \
      --prefix PATH : ${pkgs.lib.makeBinPath extraPkgs}
  '';
}
