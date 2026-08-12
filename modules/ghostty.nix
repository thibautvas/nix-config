{
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin;

  ghosttyBin = if isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
  ghosttyCfg = pkgs.writeText "config.ghostty" (
    ''
      bold-is-bright = true
      confirm-close-surface = false
      cursor-style-blink = false
      font-feature = -calt
      font-feature = -dlig
      font-feature = -liga
      keybind = global:ctrl+grave_accent=toggle_quick_terminal
      quick-terminal-animation-duration = 0
      quick-terminal-autohide = false
      quick-terminal-position = center
      shell-integration-features = no-cursor, ssh-env
    ''
    + pkgs.lib.optionalString isDarwin ''
      macos-titlebar-style = "hidden";
      macos-option-as-alt = "left";
    ''
  );

in
pkgs.symlinkJoin {
  name = "ghostty-wrapped";
  paths = [ ghosttyBin ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/ghostty \
      --add-flags "--config-file=${ghosttyCfg}"
  '';
}
