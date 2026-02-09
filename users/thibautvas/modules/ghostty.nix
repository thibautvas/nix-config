{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  ghosttySettings = {
    confirm-close-surface = false;
    shell-integration-features = "ssh-env";
    cursor-style-blink = false;
    bold-is-bright = true;
    font-feature = [
      "-calt"
      "-dlig"
      "-liga"
    ];
    keybind = "global:ctrl+grave_accent=toggle_quick_terminal";
    quick-terminal-position = "center";
    quick-terminal-autohide = false;
    quick-terminal-animation-duration = 0;
  }
  // lib.optionalAttrs isDarwin {
    macos-titlebar-style = "hidden";
    macos-option-as-alt = "left";
  };

in
{
  programs.ghostty = {
    enable = true;
    settings = ghosttySettings;
  }
  // lib.optionalAttrs isDarwin {
    package = null; # package ghostty broken on darwin
  };
}
