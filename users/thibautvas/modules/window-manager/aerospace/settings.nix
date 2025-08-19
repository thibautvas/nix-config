{ config, lib, pkgs, ... }:

let
  mkGaps = gapsBuiltin: gapsExternal: [
    { monitor."Built-in Retina Display" = gapsBuiltin; }
    gapsExternal
  ];
  innerGaps = mkGaps 5 10;
  outerGaps = mkGaps 0 10;

  mod1 = "alt-cmd-ctrl-shift";
  mod2 = "alt-shift";
  mod3 = "alt";

in {
  programs.aerospace.userSettings = {
    accordion-padding = 20;
    gaps = {
      inner = lib.genAttrs [ "horizontal" "vertical" ] (_: innerGaps);
      outer = lib.genAttrs [ "left" "right" "top" "bottom" ] (_: outerGaps);
    };

    mode.main.binding = {
      "${mod1}-u" = [
        "flatten-workspace-tree"
        "layout h_tiles"
        "focus --dfs-index 0"
        "move left"
      ];
      "${mod1}-i" = [
        "flatten-workspace-tree"
        "layout v_accordion"
        "focus --dfs-index 0"
        "move left"
        "focus-back-and-forth"
      ];
      "${mod1}-o" = [
        "flatten-workspace-tree"
        "layout h_accordion"
      ];
      "${mod1}-p" = [
        "focus --dfs-index 0"
        "move right"
        "focus-back-and-forth"
        "move left"
        "move left"
      ];

      "${mod1}-j" = "exec-and-forget open -a Arc";
      "${mod1}-k" = "exec-and-forget open -a Ghostty";
      "${mod1}-l" = "exec-and-forget open -a Slack";
      "${mod1}-semicolon" = "exec-and-forget aerospace-lauch-code $HOME/repos/sandbox/tax-material";
      "${mod1}-n" = "exec-and-forget aerospace-move-app Arc K";
      "${mod1}-m" = "exec-and-forget aerospace-restart";
      "${mod2}-j" = "move-node-to-workspace --focus-follows-window J";
      "${mod2}-k" = "move-node-to-workspace --focus-follows-window K";
      "${mod2}-l" = "move-node-to-workspace --focus-follows-window L";
      "${mod2}-tab" = "move-node-to-monitor --focus-follows-window --wrap-around next";
      "${mod3}-j" = "workspace J";
      "${mod3}-k" = "workspace K";
      "${mod3}-l" = "workspace L";
      "${mod3}-tab" = "workspace-back-and-forth";
      "${mod3}-equal" = "resize smart +50";
      "${mod3}-minus" = "resize smart -50";
      "${mod3}-t" = "layout floating tiling";
      "${mod3}-v" = "layout vertical horizontal";
    };

    on-window-detected = [
      {
        "if".app-id = "com.apple.finder";
        run = "layout floating";
      }
      {
        "if".app-id = "company.thebrowser.Browser";
        run = "move-node-to-workspace J";
      }
      {
        "if".app-id = "com.mitchellh.ghostty";
        run = "move-node-to-workspace K";
      }
      {
        "if".app-id = "com.microsoft.VSCode";
        run = "move-node-to-workspace K";
      }
      {
        "if".app-id = "com.tinyspeck.slackmacgap";
        run = "move-node-to-workspace L";
      }
      {
        "if".app-id = "com.microsoft.Outlook";
        run = "move-node-to-workspace L";
      }
      {
        "if".app-id = "us.zoom.xos";
        run = "move-node-to-workspace L";
      }
      {
        "if".app-id = "com.cisco.secureclient.gui";
        run = "move-node-to-workspace V";
      }
      {
        "if".app-id = "com.microsoft.Excel";
        run = "move-node-to-workspace X";
      }
    ];
  };
}
