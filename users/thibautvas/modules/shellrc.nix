{
  config,
  lib,
  pkgs,
  isHost,
  isDarwin,
  ...
}:

let
  shellInit = ''
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'
    alias la='ls -Alt'
    alias mv='mv -iv'
    alias cp='cp -iv'
    bak() {
      cp -a "$1" "$1_$(date +%Y%m%d).bak"
    }

    gs() {
      git -C "''${1:-$(git rev-parse --show-toplevel)}" status --short .
    }
    gl() {
      if [[ $1 =~ ^[a-z] ]]; then
        local lb="$1..HEAD"
      else
        local lb="-n''${1:-5}"
      fi
      git log --pretty=format:'%C(auto)%h %cd %C(cyan)%an%C(auto) - %s%d' \
              --date=format:'%Y-%m-%d %H:%M' --graph $lb
    }
    alias ga='git add --verbose'
    alias gc='git commit'
    alias ge='git commit --amend --no-edit'
    alias gd='git diff'
    alias gt='git difftool'
    alias gr='git restore'
    alias gu='git restore --staged'

    gb() {
      if [[ -n "$1" ]]; then
        git checkout "$1"
        return
      fi
      git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads |
      fzf --reverse --height 7 \
          --preview 'git log --color=always -n5 \
          --pretty=format:"%C(cyan)%an%C(auto) - %s%d" {1}' \
          --bind 'enter:become(git checkout {1})' \
          --bind 'ctrl-a:become(git checkout -b {q})' \
          --bind 'ctrl-x:become(git branch -D {1})'
    }

    _dcd() {
      [[ "$2" == '.' ]] && { cd "$1"; return; }
      if [[ -n "$2" ]]; then
        local target=$(fd -L -t d --base-directory "$1" "^$2" | fzf --filter "$2" | head -n1)
      else
        local target=$(fd -L -t d --base-directory "$1" | fzf --reverse --height 10)
      fi
      [[ -n "$target" ]] && cd "$1/$target"
    }
    alias jd="_dcd $WORK_DIR"
    alias jg='_dcd "$(git rev-parse --show-toplevel 2>/dev/null)"'
    alias jl="_dcd $HOME/Downloads"

    vi() {
      if [[ -n "$1" ]]; then
        nvim "$1"
      else
        nvim +"$PICKER_CMD"
      fi
    }
    jv() {
      _dcd "$WORK_DIR" "$1" && nvim +"$PICKER_CMD"
    }

    nsp() {
      cmd=(nix shell)
      for pkg in "$@"; do
        cmd+=("nixpkgs#$pkg")
      done
      ''${cmd[@]}
    }
    nrp() {
      nix run nixpkgs#$@
    }
  '';

  mkPrompt =
    shell:
    let
      escapes = shellEscapes.${shell};
      colors = fmtColors.${shell};
      promptColor = lib.attrByPath [ systemColor ] colors.default colors;
    in
    ''
      set_custom_prompt() {
        local exit_status=$?
        local active_user user_color project branch active_dir dir_color active_shell

        active_user='[${escapes.user}@${escapes.host}]'

        if [[ exit_status -eq 0 ]]; then
          user_color='${promptColor}'
        else
          user_color='${colors.red}'
        fi

        if { read -r project; read -r branch; } < <(
          git rev-parse --show-toplevel --abbrev-ref HEAD 2>/dev/null
        ); then
          active_dir="''${project##*/}:$branch ''${PWD/#$project/${escapes.home}}"
          dir_color='${colors.yellow}'
        else
          active_dir='${escapes.pwd}'
          dir_color='${colors.blue}'
        fi

        if [[ $PATH == /nix/store/* ]]; then
          active_shell=''${PATH%%/bin*}
          active_shell="(''${active_shell#*-}-env) "
        fi

        PS1="$active_shell$user_color$active_user $dir_color$active_dir\$ ${colors.default}"
      }
    '';

  shellEscapes = {
    bash = {
      user = "\\u";
      host = "\\h";
      pwd = "\\w";
      home = "'~'";
    };
    zsh = {
      user = "%n";
      host = "%m";
      pwd = "%~";
      home = "~";
    };
  };

  systemColor =
    if isDarwin then
      "green"
    else if isHost then
      "cyan"
    else
      "magenta";

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

  shellPrompt = {
    bash = mkPrompt "bash" + ''
      PROMPT_COMMAND='set_custom_prompt'
    '';
    zsh = mkPrompt "zsh" + ''
      precmd_functions+=('set_custom_prompt')
    '';
  };

in
{
  programs.bash = {
    enable = (!isDarwin);
    initExtra = shellPrompt.bash + shellInit;
  };

  programs.zsh = {
    enable = isDarwin;
    defaultKeymap = "emacs";
    initContent = shellPrompt.zsh + shellInit;
  };
}
