{
  config,
  lib,
  pkgs,
  isHost,
  isDarwin,
  ...
}:

let
  shellrc = import ./settings.nix {
    inherit pkgs isHost isDarwin;
  };
  inherit (shellrc)
    pack
    env
    shellInit
    shellPrompt
    ;

in
{
  home = {
    packages = pack;
    sessionVariables = env;
  };

  programs.bash = {
    enable = (!isDarwin);
    initExtra = shellPrompt.bash + shellInit;
  };

  programs.zsh = {
    enable = isDarwin;
    defaultKeymap = "emacs";
    initContent = shellPrompt.zsh + shellInit;
  };
}
