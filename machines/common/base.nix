{
  pkgs,
  lib,
  isHost,
  dotfiles,
  flakes,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv.hostPlatform) system;

  impPkgs = lib.optionals isHost [ flakes.self.packages.${system}.imp ];

  gitWrapped = {
    extraPkgs = lib.optionals (!isDarwin) [ pkgs.gitMinimal ]; # config issue on darwin
    cfg = lib.concatMapStringsSep "\n" lib.generators.toGitINI [
      {
        include.path = dotfiles + "/git/config";
        core.excludesFile = dotfiles + "/git/ignore";
      }
    ];
  };

  bashWrapped = {
    inherit
      ((import ../../modules/bash.nix {
        inherit pkgs dotfiles;
      }).passthru
      )
      extraPkgs
      ;
    cfg =
      let
        promptColor =
          if isDarwin then
            "32"
          else if isHost then
            "36"
          else
            "35";
      in
      builtins.replaceStrings [ "35" ] [ promptColor ] (builtins.readFile (dotfiles + "/bash/bashrc"));
  };

in
{
  environment.systemPackages = impPkgs ++ bashWrapped.extraPkgs ++ gitWrapped.extraPkgs;

  environment.etc.gitconfig.text = gitWrapped.cfg;

  programs.bash = {
    enable = true;
    interactiveShellInit = bashWrapped.cfg;
  };
}
