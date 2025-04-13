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
          tmux new-window -t "$title":0 -c "$target"
          tmux send-keys -t "$title":0 'lazygit' Enter
        fi
      tmux new-window -t "$title":2 -c "$target"
      tmux send-keys -t "$title":2 'nvim +Telescope\ find_files' Enter
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

      if declare -p SSH_CLIENT &>/dev/null; then
        sessions=$(
          echo "$local_sessions" | sed 's/.*/\x1b[35m&/'
          echo 'new session' | sed 's/.*/\x1b[3m&/'
        )
      else
        remote_sessions=$(cat $HOME/.cache/mozart/tmux_sessions.txt 2>/dev/null)
        sessions=$(
          echo "$local_sessions" | sed 's/.*/\x1b[32m&/'
          echo 'new session' | sed 's/.*/\x1b[3m&/'
          echo "$remote_sessions" | sed 's/.*/\x1b[0;35m&/'
          echo 'new mozart session' | sed 's/.*/\x1b[3m&/'
        )
      fi

      target=$(printf "%s\n" "$sessions" | fzf --ansi --reverse --height 10)

      if [[ -z $target ]]; then
        exit 1
      elif echo "$local_sessions" | grep -qF "$target"; then
        $TMUX_ATTACH -t $(echo "$target" | cut -d : -f1)
      elif [[ "$target" == 'new session' ]]; then
        tmux-new-session
      else
        if echo "$remote_sessions" | grep -qF "$target"; then
          ssh mozart -t "LC_ALL=en_US.UTF-8 tmux attach-session -t $(echo $target | cut -d : -f1)"
        elif [[ "$target" == 'new mozart session' ]]; then
          ssh mozart -t "LC_ALL=en_US.UTF-8 tmux-new-session"
        fi
        [[ $? -eq 0 ]] && ssh mozart -t 'tmux list-sessions' > "$HOME/.cache/mozart/tmux_sessions.txt"
      fi
    fi
  '';

in {
  home.packages = [
    tmuxNewSession
    tmuxAttachSession
  ];
}
