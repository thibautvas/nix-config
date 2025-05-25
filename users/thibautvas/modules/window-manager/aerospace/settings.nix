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
      "${mod1}-t" = [
        "flatten-workspace-tree"
        "layout h_accordion"
      ];
      "${mod1}-r" = [
        "flatten-workspace-tree"
        "layout h_tiles"
        "focus --dfs-index 0"
        "move left"
      ];
      "${mod1}-e" = [
        "flatten-workspace-tree"
        "layout v_accordion"
        "focus --dfs-index 0"
        "move left"
        "focus-back-and-forth"
      ];
      "${mod1}-w" = [
        "flatten-workspace-tree"
        "layout h_tiles"
      ];
      "${mod1}-q" = [
        "focus --dfs-index 0"
        "move right"
        "focus-back-and-forth"
        "move left"
        "move left"
      ];

      "${mod1}-f" = "exec-and-forget open -a Arc";
      "${mod1}-d" = "exec-and-forget open -a Ghostty";
      "${mod1}-s" = "exec-and-forget open -a Slack";
      "${mod1}-a" = "exec-and-forget open -a \"Visual Studio Code\"";
      "${mod1}-v" = "exec-and-forget aerospace-move-app Arc D";
      "${mod1}-c" = "exec-and-forget aerospace-restart";
      "${mod1}-x" = "exec-and-forget open -a \"Cisco Secure Client\"";
      "${mod1}-z" = "exec-and-forget open -a \"Visual Studio Code\" $HOME/repos/sandbox/tax-material";
      "${mod2}-f" = "move-node-to-workspace --focus-follows-window F";
      "${mod2}-d" = "move-node-to-workspace --focus-follows-window D";
      "${mod2}-s" = "move-node-to-workspace --focus-follows-window S";
      "${mod2}-tab" = "move-node-to-monitor --focus-follows-window --wrap-around next";
      "${mod3}-f" = "workspace F";
      "${mod3}-d" = "workspace D";
      "${mod3}-s" = "workspace S";
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
        run = "move-node-to-workspace F";
      }
      {
        "if".app-id = "com.mitchellh.ghostty";
        run = "move-node-to-workspace D";
      }
      {
        "if".app-id = "com.microsoft.VSCode";
        run = "move-node-to-workspace D";
      }
      {
        "if".app-id = "com.tinyspeck.slackmacgap";
        run = "move-node-to-workspace S";
      }
      {
        "if".app-id = "com.microsoft.Outlook";
        run = "move-node-to-workspace S";
      }
      {
        "if".app-id = "us.zoom.xos";
        run = "move-node-to-workspace S";
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
