{ config, lib, pkgs, ... }:

let
  shellPrompt = ''
    set_custom_prompt() {
      if [[ $? -eq 0 ]]; then
        local user_color=$(eval "echo \$$HOST_COLOR")
      else
        local user_color="$RED"
      fi
      local active_user="[$USER@$(uname -n)]"

      local project branch active_dir dir_color
      if project=$(git rev-parse --show-toplevel 2>/dev/null); then
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        active_dir="$(basename "$project"):$branch $(echo "$PWD" | sed "s|^$project|~|")"
        dir_color="$YELLOW"
      else
        active_dir=$(echo "$PWD" | sed "s|^$HOME|~|")
        dir_color="$BLUE"
      fi

      if [[ -n "$name" ]]; then
        local active_shell="($name) "
      fi
      if [[ -n "$VIRTUAL_ENV" ]]; then
        local active_venv="($(basename $VIRTUAL_ENV)) "
      fi

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
    alias tree='tree -C'
    alias ls='ls --color=auto'
    alias la='ls -A'
    alias ll='ls -l'
    alias lla='ls -lA'
    alias mv='mv -iv'
    alias cp='cp -iv'
    bak() {
      cp -a "$1" "$1_$(date +%Y%m%d).bak"
    }

    alias gs='git -C "$(git rev-parse --show-toplevel)" status --short'
    alias grs='git status --short .'
    gl() {
      local length; [[ -n "$1" ]] && length="$1" || length=5
      git log --graph --oneline --max-count=$length \
        --pretty=format:'%C(auto)%h%Creset %cd %C(cyan)%an%Creset - %s%C(auto)%d%Creset' \
        --date=format:'%Y-%m-%d %H:%M' HEAD
    }
    alias ga='git add --verbose'
    alias gap='git add --patch'
    alias gc='git commit'
    alias gcm='git commit --message'
    alias gam='git commit --amend'
    alias gane='git commit --amend --no-edit'
    alias gd='git diff'
    alias gds='git diff --staged'
    alias gdc='git diff HEAD~1 HEAD'
    alias gr='git restore'
    alias grp='git restore --patch'
    alias gu='git restore --staged'
    alias gup='git restore --staged --patch'
    alias lg='lazygit' # https://github.com/jesseduffield/lazygit

    gco() {
      local target
      if [[ -n "$1" ]]; then
        git checkout "$1" 2>/dev/null && return 0
        target=$(
          git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads |
          grep -F "$1" |
          head -n 1
        )
      else
        target=$(
          git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads |
          fzf --reverse --height 7 --preview \
            "git log --color=always --oneline --max-count=5 \
              --pretty=format:'%C(cyan)%an%Creset - %s%C(auto)%d%Creset' {}"
        )
      fi
      [[ -n "$target" ]] && git checkout "$target"
    }

    direct_cd() {
      local target
      if [[ -n "$2" ]]; then
        local rank; [[ -n "$3" ]] && rank="$3" || rank=1
        cd "$1/$2" 2>/dev/null && return 0
        target=$(
          fd --base-directory "$1" --type directory "^$2" --absolute-path |
          sed -n $rank"p"
        )
      else
        target=$(
        { echo './'; fd --base-directory "$1" --type directory; } |
        awk -F '/' '{printf "%-20s # %s\n", $(NF-1), $0}' |
        fzf --reverse --height 10 --preview "tree -CaL 1 $1/{3}" |
        sed "s:^[^#]*# :$1/:"
        )
      fi
      [[ -n "$target" ]] && cd "$target"
    }
    alias dcd="direct_cd $HOST_PROJECT_DIR"
    alias wcd='direct_cd $PWD'
    alias gcd='direct_cd "$(git rev-parse --show-toplevel 2>/dev/null || echo $HOST_PROJECT_DIR/git)"'

    vi() {
      if [[ -n "$1" ]]; then
        nvim "$1"
      else
        nvim +Telescope\ find_files
      fi
    }

    alias tns='tmux-new-session'
    alias tas='tmux-attach-session'
    alias tls='tmux list-sessions'
    alias tks='tmux kill-session'
  '';

in {
  programs.bash = {
    enable = true;
    initExtra = shellPrompt + shellInit;
    shellAliases = { rf = "source $HOME/.bashrc"; };
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    initExtra = shellPrompt + shellInit;
    shellAliases = { rf = "source $HOME/.zshrc"; };
  };
}
