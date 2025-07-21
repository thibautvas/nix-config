{ config, lib, pkgs, ... }:

let
  ansiColors = {
    DEFAULT = "\x1b[0m";
    BLACK = "\x1b[30m";
    RED = "\x1b[31m";
    GREEN = "\x1b[32m";
    YELLOW = "\x1b[33m";
    BLUE = "\x1b[34m";
    MAGENTA = "\x1b[35m";
    CYAN = "\x1b[36m";
    WHITE = "\x1b[37m";
  };
  hostColor = config.home.sessionVariables.HOST_COLOR;
  colorCode = lib.attrsets.attrByPath [hostColor] ansiColors.default ansiColors;

  tmuxListSessions = pkgs.writeShellScriptBin "tls" ''
    results="{
      tmux list-sessions | cut -d':' -f1 | sed 's/^/\${colorCode}/; s/\$/\x1b[0m/';
      fd --base-directory \"$HOST_PROJECT_DIR\" --type directory | sed 's/\/$//';
    }"

    target=$(
      [[ -n "$1" ]] &&
      realpath "$1" ||
      eval $results |
      fzf --ansi --reverse --height 10 --scheme=path \
          --bind "ctrl-x:execute-silent(tmux kill-session -t {1})+reload($results)"
    )

    [[ -z "$target" ]] && exit 1
    [[ -d "$target" ]] && path="$target" || path="$HOST_PROJECT_DIR/$target"
    title=$(basename "$target" | sed 's/\.//g')
    tmux new-session -d -s "$title" -c "$path" 2>/dev/null &&
    tmux new-window -t "$title":2 -c "$path" 'nvim +"$PICKER_CMD"'
    tmux attach-session -t "$title" 2>/dev/null ||
    tmux switch-client -t "$title" 2>/dev/null
  '';

in {
  home.packages = [ tmuxListSessions ];
}
