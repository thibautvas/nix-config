{ config, lib, pkgs, ... }:

let
  promptColor = config.home.sessionVariables.PROMPT_COLOR;
  ansiColors = {
    default = "0";
    red = "31";
    green = "32";
    yellow = "33";
    blue = "34";
    magenta = "35";
    cyan = "36";
  } // {
    prompt = ansiColors.${promptColor};
  };
  fmtPromptColor = "\x1b[${ansiColors.prompt}m";

  tmuxListSessions = pkgs.writeShellScriptBin "tls" ''
    results="{
      tmux list-sessions | cut -d':' -f1 | sed 's/^/\${fmtPromptColor}/; s/\$/\x1b[0m/';
      fd --base-directory \"$WORK_DIR\" --type directory | sed 's/\/$//';
    }"

    target=$(
      [[ -n "$1" ]] &&
      realpath "$1" ||
      eval $results |
      fzf --ansi --reverse --height 10 --scheme=path \
          --bind "ctrl-x:execute-silent(tmux kill-session -t {1})+reload($results)"
    )

    [[ -z "$target" ]] && exit 1
    [[ -d "$target" ]] && path="$target" || path="$WORK_DIR/$target"
    title=$(basename "$target" | sed 's/\.//g')
    tmux new-session -d -s "$title" -c "$path" 2>/dev/null &&
    tmux new-window -t "$title":2 -c "$path" 'nvim +"$PICKER_CMD"'
    tmux attach-session -t "$title" 2>/dev/null ||
    tmux switch-client -t "$title" 2>/dev/null
  '';

in {
  home.packages = [ tmuxListSessions ];
}
