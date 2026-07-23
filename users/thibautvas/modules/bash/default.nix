{
  pkgs,
  isHost,
  isDarwin,
  dotfiles,
  ...
}:

let
  extraPkgs =
    (import ./package.nix {
      inherit pkgs dotfiles;
    }).passthru.runtimeInputs;

  promptColor =
    if isDarwin then
      "32"
    else if isHost then
      "36"
    else
      "35";
  rawRc = builtins.readFile "${dotfiles}/bash/bashrc";
  fmtRc = builtins.replaceStrings [ "35" ] [ promptColor ] rawRc;

in
{
  home.packages = extraPkgs;

  programs.bash = {
    enable = true;
    initExtra = fmtRc;
  };
}
