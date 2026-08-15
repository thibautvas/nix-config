{
  pkgs,
  ...
}:

let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv) isDarwin;

  ghosttyBin = if isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

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
  }
  // lib.optionalAttrs isDarwin {
    macos-option-as-alt = "left";
    macos-titlebar-style = "hidden";
  };

  ghosttyCfgPath = pkgs.writeText "config.ghostty" (
    lib.generators.toKeyValue {
      listsAsDuplicateKeys = true;
    } ghosttyCfg
  );

in
pkgs.symlinkJoin {
  name = "ghostty-wrapped";
  paths = [ ghosttyBin ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/ghostty \
      --add-flags "--config-file=${ghosttyCfgPath}"
  '';
}
