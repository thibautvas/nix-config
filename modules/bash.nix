{
  self,
  pkgs,
  ...
}:

let
  bashRc = self + /dotfiles/bashrc;

  extraPkgs = with pkgs; [
    fd
    fzf
    ripgrep
  ];

in
pkgs.symlinkJoin {
  name = "bash-wrapped";
  meta.mainProgram = "bash";
  paths = [ pkgs.bashInteractive ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/bash \
      --add-flags "--rcfile ${bashRc}" \
      --prefix PATH : ${pkgs.lib.makeBinPath extraPkgs}
  '';
  passthru = {
    inherit extraPkgs;
  };
}
