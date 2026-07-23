{
  lib,
  dotfiles,
  ...
}:

{
  programs.git = {
    enable = true;
    includes = [
      {
        path = "${dotfiles}/git/config";
      }
    ];
    ignores = lib.splitString "\n" (builtins.readFile "${dotfiles}/git/ignore");
  };
}
