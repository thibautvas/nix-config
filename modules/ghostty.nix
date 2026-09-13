{
  lib,
  ghostty,
  writeText,
  symlinkJoin,
  makeWrapper,
  ...
}:

let
  ghosttyCfg = {
    bold-color = "bright";
    confirm-close-surface = false;
    cursor-style-blink = false;
    font-feature = [
      "-calt"
      "-dlig"
      "-liga"
    ];
    shell-integration-features = "no-cursor, ssh-env";
    macos-option-as-alt = "left";
    macos-titlebar-style = "hidden";
  };

  ghosttyCfgPath = writeText "config.ghostty" (
    lib.generators.toKeyValue {
      listsAsDuplicateKeys = true;
    } ghosttyCfg
  );

in
symlinkJoin {
  name = "ghostty-wrapped";
  paths = [ ghostty ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/ghostty \
      --add-flags "--config-file=${ghosttyCfgPath}"
  '';
}
