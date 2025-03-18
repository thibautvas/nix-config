{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      confirm-close-surface = false;
      macos-titlebar-style = "hidden";
      window-padding-x = 10;
      window-padding-y = "10,5";
      background-opacity = 0.9;
      macos-option-as-alt = "left";
      shell-integration-features = "no-cursor";
      cursor-style-blink = false;
      bold-is-bright = true;
      font-feature = [ "-calt" "-dlig" "-liga" ];
      keybind = "global:ctrl+grave_accent=toggle_quick_terminal";
      quick-terminal-position = "center";
      quick-terminal-autohide = false;
      quick-terminal-animation-duration = 0;
    };
  };
}
