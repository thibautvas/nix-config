{
  pkgs,
  lib,
  dotfiles,
  ...
}:

{
  environment = {
    systemPackages = lib.optionals (!pkgs.stdenv.isDarwin) [ pkgs.gitMinimal ]; # config issue on darwin
    etc.gitconfig.text = lib.concatMapStringsSep "\n" lib.generators.toGitINI [
      {
        include.path = dotfiles + "/git/config";
        core.excludesFile = dotfiles + "/git/ignore";
      }
    ];
  };
}
