{
  self,
  lib,
  bashInteractive,
  fd,
  fzf,
  ripgrep,
  symlinkJoin,
  makeWrapper,
  ...
}:

let
  bashRc = self + /dotfiles/bashrc;

  extraPkgs = [
    fd
    fzf
    ripgrep
  ];

in
symlinkJoin {
  name = "bash-wrapped";
  meta.mainProgram = "bash";
  paths = [ bashInteractive ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/bash \
      --add-flags "--rcfile ${bashRc}" \
      --prefix PATH : ${lib.makeBinPath extraPkgs}
  '';
  passthru = {
    inherit extraPkgs;
  };
}
