{ config, lib, pkgs, ... }:

let
  shellPrompt = ''
    set_custom_prompt() {
      [[ $? -eq 0 ]] &&
      local user_color=$(eval "echo \$$HOST_COLOR") ||
      local user_color="$RED"

      local active_user="[$USER@$(uname -n)]"

      local project
      project=$(git rev-parse --show-toplevel 2>/dev/null) && {
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        local active_dir="$(basename "$project"):$branch $(echo "$PWD" | sed "s:^$project:~:")"
        local dir_color="$YELLOW"
      } || {
        local active_dir=$(echo "$PWD" | sed "s:^$HOME:~:")
        local dir_color="$BLUE"
      }

      [[ -n "$name" ]] &&
      local active_shell="($name) " || {
        [[ $(echo $PATH | cut -d':' -f1) == /nix/store/* ]] &&
        local active_shell="($(echo $PATH | cut -d'-' -f2)-env) "
      }
      [[ -n "$VIRTUAL_ENV" ]] &&
      local active_venv="($(basename $VIRTUAL_ENV)) "

      PS1="$active_shell$active_venv$user_color$active_user $dir_color$active_dir\$ $DEFAULT"
    }

    if [[ -n "$BASH_VERSION" ]]; then
      DEFAULT='\[\e[0m\]'; RED='\[\e[31m\]'; GREEN='\[\e[32m\]'; YELLOW='\[\e[33m\]'; BLUE='\[\e[34m\]'; MAGENTA='\[\e[35m\]'; CYAN='\[\e[36m\]'
      PROMPT_COMMAND='set_custom_prompt'
    elif [[ -n "$ZSH_VERSION" ]]; then
      DEFAULT='%f'; RED='%F{red}'; GREEN='%F{green}'; YELLOW='%F{yellow}'; BLUE='%F{blue}'; MAGENTA='%F{magenta}'; CYAN='%F{cyan}'
      precmd_functions+=('set_custom_prompt')
    fi
  '';

  shellInit = ''
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias ocd="cd $PWD"
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'
    alias la='ls -Alt'
    alias mv='mv -iv'
    alias cp='cp -iv'
    bak() {
      cp -a "$1" "$1_$(date +%Y%m%d).bak"
    }

    gs() {
      local root="''${1:-$(git rev-parse --show-toplevel)}"
      git -C "$root" status --short .
    }
    gl() {
      git log --graph --oneline --max-count="''${1:-5}" \
        --pretty=format:'%C(auto)%h%Creset %cd %C(cyan)%an%Creset - %s%C(auto)%d%Creset' \
        --date=format:'%Y-%m-%d %H:%M' HEAD
    }
    alias ga='git add --verbose'
    alias gc='git commit'
    alias gane='git commit --amend --no-edit'
    alias gd='git diff'
    alias gt='git difftool'
    alias gr='git restore'
    alias gu='git restore --staged'

    gco() {
      git checkout "$1" 2>/dev/null && return 0
      local branches=$(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads)
      local target=$(
        [[ -n "$1" ]] && echo "$branches" | grep "^$1" | head -n1 ||
        echo "$branches" | fzf --reverse --height 7 --preview \
          "git log --color=always --oneline --max-count=5 \
          --pretty=format:'%C(cyan)%an%Creset - %s%C(auto)%d%Creset' {}"
      )
      git checkout "$target"
    }

    direct_cd() {
      local results=$(
        echo './'
        fd --base-directory "$1" --type directory "^$2"
      )
      local target=$(
        [[ -n "$2" ]] &&
        printf '%s\n' "$results" |
        fzf --filter="$2" |
        sed -n "''${3:-1}p" ||
        echo "$results" |
        awk -F '/' '{printf "%-20s # %s\n", $(NF-1), $0}' |
        fzf --reverse --height 10 --preview "ls --color=always -1A $1/{3}" |
        sed 's/.* # //'
      )
      [[ -n "$target" ]] && cd "$1/$target"
    }
    alias dcd="direct_cd $HOST_PROJECT_DIR"
    alias gcd='direct_cd "$(git rev-parse --show-toplevel 2>/dev/null || echo $HOST_PROJECT_DIR/git)"'

    vi() {
      [[ -n "$1" ]] && nvim "$1" || nvim +"$PICKER_CMD"
    }

    alias tls='tmux list-sessions'
    alias tks='tmux kill-session'
  '';

in {
  programs.bash = {
    enable = true;
    initExtra = shellPrompt + shellInit;
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    initContent = shellPrompt + shellInit;
  };
}
