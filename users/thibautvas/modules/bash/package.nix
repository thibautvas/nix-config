{
  pkgs,
  dotfiles,
  ...
}:

let
  bashRc = "${dotfiles}/bash/bashrc";
  runtimeInputs = with pkgs; [
    fd
    fzf
    ripgrep
  ];

in
(pkgs.writeShellApplication {
  name = "bash";
  inherit runtimeInputs;
  text = "exec ${pkgs.bashInteractive}/bin/bash --rcfile ${bashRc}";
}).overrideAttrs
  (old: {
    passthru = (old.passthru or { }) // {
      inherit runtimeInputs;
    };
  })
