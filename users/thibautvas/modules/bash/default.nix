{
  config,
  lib,
  pkgs,
  isHost,
  isDarwin,
  flakes,
  ...
}:

let
  extraPkgs =
    (import ./package.nix {
      inherit pkgs;
      inherit (flakes) dotfiles;
    }).passthru.runtimeInputs;

  promptColor =
    if isDarwin then
      "32"
    else if isHost then
      "36"
    else
      "35";
  rawRc = builtins.readFile "${flakes.dotfiles}/bash/bashrc";
  fmtRc = builtins.replaceStrings [ "35" ] [ promptColor ] rawRc;

in
{
  home.packages = extraPkgs;

  programs.bash = {
    enable = true;
    initExtra = fmtRc;
  };
}
