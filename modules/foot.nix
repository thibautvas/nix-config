{
  pkgs,
  ...
}:

let
  fontCfg = pkgs.makeFontsConf {
    fontDirectories = [ pkgs.nerd-fonts.jetbrains-mono ];
  };

  footCfg = {
    main = {
      font = "JetBrainsMono Nerd Font:size=12";
    };
    colors-dark = {
      foreground = "c5c8c6";
      background = "1d1f21";
      regular0 = "1d1f21";
      regular1 = "cc6666";
      regular2 = "b5bd68";
      regular3 = "f0c674";
      regular4 = "81a2be";
      regular5 = "b294bb";
      regular6 = "8abeb7";
      regular7 = "c5c8c6";
      bright0 = "666666";
      bright1 = "d54e53";
      bright2 = "b9ca4a";
      bright3 = "e7c547";
      bright4 = "7aa6da";
      bright5 = "c397d8";
      bright6 = "70c0b1";
      bright7 = "eaeaea";
    };
  };

  footCfgPath = pkgs.writeText "foot.ini" (pkgs.lib.generators.toINI { } footCfg);

in
pkgs.symlinkJoin {
  name = "foot-wrapped";
  paths = [ pkgs.foot ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/foot \
      --set FONTCONFIG_FILE ${fontCfg}
    ln -sf ${footCfgPath} $out/etc/xdg/foot/foot.ini
  '';
}
