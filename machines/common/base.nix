{
  self,
  machine,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  impPkgs = lib.optionals (machine != "guest") [ self.packages.${system}.imp ];

  gitWrapped = {
    extraPkgs = lib.optionals (machine != "darwin") [ pkgs.gitMinimal ]; # config issue on darwin
    cfgPath = self + /dotfiles/gitconfig;
  };

  bashWrapped = {
    inherit (self.packages.${system}.bash.passthru) extraPkgs;
    cfg =
      let
        bashRc = builtins.readFile (self + /dotfiles/bashrc);
        promptColor = {
          host = "36"; # cyan
          guest = "35"; # magenta
          darwin = "32"; # green
        };
      in
      builtins.replaceStrings [ "35" ] [ promptColor.${machine} ] bashRc;
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
