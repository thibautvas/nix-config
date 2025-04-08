{ config, pkgs, lib, ... }:

let
  ghosttySettings = {
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

  renderSettings = name: value:
  if lib.isList value then
    lib.concatStringsSep "\n" (map (v: "${name} = ${toString v}") value)
  else if lib.isBool value then
    "${name} = ${if value then "true" else "false"}"
  else
    "${name} = ${toString value}";

  ghosttySettingsText = lib.concatStringsSep "\n" (lib.mapAttrsToList renderSettings ghosttySettings);

in {
  # package ghostty marked as broken on aarch64-darwin
  options.ghostty.isBroken = lib.mkOption { default = pkgs.stdenv.isDarwin; };

  config = lib.mkMerge [
    (lib.mkIf (!config.ghostty.isBroken) {
      programs.ghostty = {
        enable = true;
        settings = ghosttySettings;
      };
    })

    (lib.mkIf config.ghostty.isBroken {
      xdg.configFile."ghostty/config".text = ghosttySettingsText;
    })
  ];
}
