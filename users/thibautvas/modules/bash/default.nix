{
  pkgs,
  isHost,
  dotfiles,
  ...
}:

let
  inherit
    ((import ./package.nix {
      inherit pkgs dotfiles;
    }).passthru
    )
    extraPkgs
    ;

  promptColor =
    if pkgs.stdenv.isDarwin then
      "32"
    else if isHost then
      "36"
    else
      "35";
  rawRc = builtins.readFile (dotfiles + "/bash/bashrc");
  fmtRc = builtins.replaceStrings [ "35" ] [ promptColor ] rawRc;

in
{
  environment.systemPackages = extraPkgs;

  programs.bash = {
    enable = true;
    interactiveShellInit = fmtRc;
  };
}
