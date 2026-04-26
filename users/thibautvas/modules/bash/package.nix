{
  pkgs,
  isHost,
  isDarwin,
  ...
}:

let
  inherit (pkgs) lib;

  shellrc = import ./settings.nix {
    inherit pkgs isHost isDarwin;
  };

  extraBinPath = lib.makeBinPath (shellrc.pack);

  envFlags = lib.concatMapAttrsStringSep " \\\n" (
    name: value: "--set ${name} ${lib.escapeShellArg value}"
  ) shellrc.env;

  bashInitFile = pkgs.writeText "bashrc" (shellrc.shellInit + shellrc.shellPrompt.bash);

in
pkgs.symlinkJoin {
  name = "bash-wrapped";
  paths = [ pkgs.bash ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  meta.mainProgram = "bash";
  postBuild = ''
    wrapProgram $out/bin/bash \
      --add-flags "--rcfile ${bashInitFile}" \
      --prefix PATH : ${extraBinPath} \
      ${envFlags}
  '';
}
