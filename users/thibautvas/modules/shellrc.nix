{ config, lib, pkgs, isDarwin, isLinux, ... }:

let
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
    alias ge='git commit --amend --no-edit'
    alias gd='git diff'
    alias gt='git difftool'
    alias gr='git restore'
    alias gu='git restore --staged'

    gco() {
      git checkout "$1" 2>/dev/null && return 0
      local results=$(
        git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads
        git log --max-count=5 --pretty=format:'%h' HEAD~1
      )
      local target=$(
        [[ -n "$1" ]] && echo "$results" | grep "^$1" | head -n1 ||
        echo "$results" | fzf --reverse --height 7 --preview \
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
  '';

  mkShellPrompt = colors: ''
    set_custom_prompt() {
      [[ $? -eq 0 ]] &&
      local user_color='${lib.attrByPath [hostColor] colors.default colors}' ||
      local user_color='${colors.red}'

      local active_user="[$USER@$(uname -n)]"

      local project
      project=$(git rev-parse --show-toplevel 2>/dev/null) && {
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        local active_dir="$(basename "$project"):$branch $(echo "$PWD" | sed "s:^$project:~:")"
        local dir_color='${colors.yellow}'
      } || {
        local active_dir=$(echo "$PWD" | sed "s:^$HOME:~:")
        local dir_color='${colors.blue}'
      }

      [[ -n "$name" ]] &&
      local active_shell="($name) " || {
        [[ $(echo $PATH | cut -d':' -f1) == /nix/store/* ]] &&
        local active_shell="($(echo $PATH | cut -d'-' -f2)-env) "
      }
      [[ -n "$VIRTUAL_ENV" ]] &&
      local active_venv="($(basename $VIRTUAL_ENV)) "

      PS1="$active_shell$active_venv$user_color$active_user $dir_color$active_dir\$ ${colors.default}"
    }
  '';

  ansiColors = {
    default = "0";
    red = "31";
    green = "32";
    yellow = "33";
    blue = "34";
    magenta = "35";
    cyan = "36";
  };

  fmtColors = {
    bash = lib.mapAttrs (_: value: "\\[\\e[${value}m\\]") ansiColors;
    zsh = lib.mapAttrs (name: _: "%F{${name}}") ansiColors // {
      default = "%f";
    };
  };

  hostColor = config.home.sessionVariables.HOST_COLOR;

  shellPrompt = {
    bash = mkShellPrompt fmtColors.bash + ''
      PROMPT_COMMAND='set_custom_prompt'
    '';
    zsh = mkShellPrompt fmtColors.zsh + ''
      precmd_functions+=('set_custom_prompt')
    '';
  };

in {
  programs.bash = {
    enable = isLinux;
    initExtra = shellPrompt.bash + shellInit;
  };

  programs.zsh = {
    enable = isDarwin;
    defaultKeymap = "emacs";
    initContent = shellPrompt.zsh + shellInit;
  };
}
