{ config, lib, pkgs, ... }:

let
  tmuxNewSession = pkgs.writeShellScriptBin "tns" ''
    target=$(
      [[ -n "$1" ]] &&
      realpath "$1" ||
      fd --base-directory "$HOST_PROJECT_DIR" --type directory |
      awk -F '/' '{printf "%-20s # %s\n", $(NF-1), $0}' |
      fzf --reverse --height 10 --preview "tree -CaL 1 $HOST_PROJECT_DIR/{3}" |
      sed "s:^.*# \(.*\)/$:$HOST_PROJECT_DIR/\1:"
    )

    [[ -z "$target" ]] && exit 1
    project=$(git -C "$target" rev-parse --show-toplevel 2>/dev/null)
    title=$(basename "''${project:-''$target}" | sed 's/\.//g')

    tmux new-session -d -s "$title" -c "$target" 2>/dev/null &&
    tmux new-window -t "$title":2 -c "$target" 'nvim +Telescope\ find_files' &&
    [[ -n "$project" ]] && tmux new-window -d -t "$title":0 -c "$target" 'lazygit'

    tmux attach-session -t "$title" 2>/dev/null || tmux switch-client -t "$title"
  '';

  tmuxAttachSession = pkgs.writeShellScriptBin "tas" ''
    [[ -n "$1" ]] && {
      tmux attach-session -t "$1" 2>/dev/null ||
      tmux switch-client -t "$1" 2>/dev/null
      exit
    }

    sessions=$(
      tmux list-sessions 2>/dev/null
      echo 'new session'
    )

    target=$(
      printf '%s\n' "$sessions" |
      fzf --ansi --reverse --height 10 |
      cut -d':' -f1
    )

    [[ -z "$target" ]] && exit 1
    tmux attach-session -t "$target" 2>/dev/null ||
    tmux switch-client -t "$target" 2>/dev/null ||
    tns
  '';

in {
  home.packages = [
    tmuxNewSession
    tmuxAttachSession
  ];
}
