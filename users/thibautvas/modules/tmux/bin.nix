{ config, lib, pkgs, ... }:

let
  tmuxNewSession = pkgs.writeShellScriptBin "tmux-new-session" ''
    if [[ -n "$1" ]]; then
      target=$(realpath "$1")
    else
      target=$(
        fd --base-directory "$HOST_PROJECT_DIR" --type directory |
        awk -F '/' '{printf "%-20s # %s\n", $(NF-1), $0}' |
        fzf --reverse --height 10 --preview "tree -CaL 1 $HOST_PROJECT_DIR/{3}" |
        sed "s:^.*# \(.*\)/:$HOST_PROJECT_DIR/\1:"
      )
      [[ -z "$target" ]] && exit 1
    fi

    if project=$(git -C "$target" rev-parse --show-toplevel 2>/dev/null); then
      title=$(basename "$project" | sed 's/\.//g')
    else
      title=$(basename "$target" | sed 's/\.//g')
    fi

    if ! tmux has-session -t "$title" 2>/dev/null; then
      tmux new-session -d -s "$title" -c "$target"
        if [[ -n "$project" ]]; then
          tmux new-window -t "$title":0 -c "$target" 'lazygit'
        fi
      tmux new-window -t "$title":2 -c "$target" 'nvim +Telescope\ find_files'
    fi

    if [[ "$2" == d* ]]; then
      exit 0
    elif [[ -n "$TMUX" ]] ; then
      tmux switch-client -t "$title"
    else
      tmux attach-session -t "$title"
    fi
  '';

  tmuxAttachSession = pkgs.writeShellScriptBin "tmux-attach-session" ''
    if [[ -n $TMUX ]]; then
      TMUX_ATTACH='tmux switch-client'
    else
      TMUX_ATTACH='tmux attach-session'
    fi

    if [[ -n $1 ]]; then
      $TMUX_ATTACH -t "$1"
    else
      local_sessions=$(tmux list-sessions 2>/dev/null)

      sessions=$(
        echo "$local_sessions" | sed 's/.*/\x1b[32m&/'
        echo 'new session' | sed 's/.*/\x1b[3m&/'
      )

      target=$(printf "%s\n" "$sessions" | fzf --ansi --reverse --height 10)

      if [[ -z $target ]]; then
        exit 1
      elif echo "$local_sessions" | grep -qF "$target"; then
        $TMUX_ATTACH -t $(echo "$target" | cut -d : -f1)
      elif [[ "$target" == 'new session' ]]; then
        tmux-new-session
      fi
    fi
  '';

in {
  home.packages = [
    tmuxNewSession
    tmuxAttachSession
  ];
}
