{
  pkgs,
  lib,
  isHost,
  flakes,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv.hostPlatform) system;

  impPkgs = lib.optionals isHost [ flakes.self.packages.${system}.imp ];

  gitWrapped = {
    extraPkgs = lib.optionals (!isDarwin) [ pkgs.gitMinimal ]; # config issue on darwin
    cfgPath = ../../dotfiles/gitconfig;
  };

  bashWrapped = {
    inherit
      ((import ../../modules/bash.nix {
        inherit pkgs;
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
      builtins.replaceStrings [ "35" ] [ promptColor ] (builtins.readFile ../../dotfiles/bashrc);
  };

in
{
  environment.systemPackages = impPkgs ++ bashWrapped.extraPkgs ++ gitWrapped.extraPkgs;

  environment.etc.gitconfig.source = gitWrapped.cfgPath;

  programs.bash = {
    enable = true;
    interactiveShellInit = bashWrapped.cfg;
  };
}
