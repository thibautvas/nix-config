{
  pkgs,
  ...
}:

let
  aeroRc = ../dotfiles/aerospace.toml;

in
pkgs.symlinkJoin {
  name = "aerospace-wrapped";
  paths = [
    pkgs.aerospace
    pkgs.choose-gui
  ];
  postBuild = ''
    mkdir -p $out/bin
    cat > $out/bin/aero <<EOF
    #!${pkgs.bashInteractive}/bin/bash
    export XDG_CONFIG_HOME="$out/etc/xdg"
    exec /usr/bin/open "$out/Applications/AeroSpace.app" "\$@"
    EOF
    chmod +x $out/bin/aero

    mkdir -p $out/etc/xdg/aerospace
    cp ${aeroRc} $out/etc/xdg/aerospace/aerospace.toml
  '';
}
