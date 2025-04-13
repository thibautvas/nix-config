{ config, lib, pkgs, isDarwin, ... }:

{
  programs.aerospace.userSettings = lib.mkIf isDarwin {
    start-at-login = true;
    accordion-padding = 20;

    gaps = {
      inner.horizontal = [{ monitor."Built-in Retina Display" = 5; } 10];
      inner.vertical = [{ monitor."Built-in Retina Display" = 5; } 10];
      outer.left = [{ monitor."Built-in Retina Display" = 0; } 10];
      outer.bottom = [{ monitor."Built-in Retina Display" = 0; } 10];
      outer.top = [{ monitor."Built-in Retina Display" = 0; } 10];
      outer.right = [{ monitor."Built-in Retina Display" = 0; } 10];
    };

    mode.main.binding = {
      alt-cmd-ctrl-shift-t = [
        "flatten-workspace-tree"
        "layout h_accordion"
      ];
      alt-cmd-ctrl-shift-r = [
          "flatten-workspace-tree"
          "layout h_tiles"
          "focus --dfs-index 0"
          "move left"
      ];
      alt-cmd-ctrl-shift-e = [
          "flatten-workspace-tree"
          "layout v_accordion"
          "focus --dfs-index 0"
          "move left"
          "focus-back-and-forth"
      ];
      alt-cmd-ctrl-shift-w = [
          "flatten-workspace-tree"
          "layout h_tiles"
      ];
      alt-cmd-ctrl-shift-q = [
          "focus --dfs-index 0"
          "move right"
          "focus-back-and-forth"
          "move left"
          "move left"
      ];
      alt-cmd-ctrl-shift-tab = "focus right --boundaries-action wrap-around-the-workspace";
      alt-cmd-ctrl-shift-space = "focus down --boundaries-action wrap-around-the-workspace";
      alt-cmd-ctrl-shift-f = "exec-and-forget open -a Arc";
      alt-cmd-ctrl-shift-d = "exec-and-forget open -a Ghostty";
      alt-cmd-ctrl-shift-s = "exec-and-forget open -a Slack";
      alt-cmd-ctrl-shift-a = "exec-and-forget open -a \"Visual Studio Code\"";
      alt-cmd-ctrl-shift-v = "exec-and-forget aerospace-move-app Arc D";
      alt-cmd-ctrl-shift-x = "exec-and-forget open -a \"Cisco Secure Client\"";
      alt-cmd-ctrl-shift-z = "exec-and-forget code $HOME/repos/sandbox/tax-material";
      alt-f = "workspace F";
      alt-d = "workspace D";
      alt-s = "workspace S";
      alt-tab = "workspace-back-and-forth";
      alt-shift-f = "move-node-to-workspace --focus-follows-window F";
      alt-shift-d = "move-node-to-workspace --focus-follows-window D";
      alt-shift-s = "move-node-to-workspace --focus-follows-window S";
      alt-shift-tab = "move-node-to-monitor --focus-follows-window --wrap-around next";
      alt-equal = "resize smart +50";
      alt-minus = "resize smart -50";
      alt-shift-p = "mode position";
    };

    mode.position.binding = {
      "1" = ["focus --dfs-index 0" "mode main"];
      "2" = ["focus --dfs-index 1" "mode main"];
      "3" = ["focus --dfs-index 2" "mode main"];
      h = ["move left" "mode main"];
      j = ["move down" "mode main"];
      k = ["move up" "mode main"];
      l = ["move right" "mode main"];
      f = ["layout floating tiling" "mode main"];
      v = ["layout vertical horizontal" "mode main"];
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
