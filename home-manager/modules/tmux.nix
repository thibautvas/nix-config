{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    mouse = true;
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";
    extraConfig = ''
      set -g status-bg black
      set -g status-fg "$HOSTCOLOR"
      set-option -g status-left-length 30
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R
    '';
  };

  imports = [
    ./tmux-opts/bin.nix
  ];
}
