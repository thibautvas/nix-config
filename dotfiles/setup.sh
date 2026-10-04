#!/usr/bin/env bash

set -euo pipefail

# set NODOT to skip installation of dotfiles
# set NOBIN to skip installation of following binaries in PATH
# set NOVIM to skip installation of nvim and plugins altogether
NIXCONF_REF="${1:-dots}"
FZF_VERSION="0.72.0"
FD_VERSION="10.4.2"
RG_VERSION="15.1.0"
NVIM_VERSION="0.12.4"
BLINK_VERSION="1.10.2"

fetch() {
  echo "==> Downloading: $1" >&2
  curl -fL "$1"
}

TMPDIR=$(mktemp -d)
RAWDOTS="https://raw.githubusercontent.com/thibautvas/nix-config/$NIXCONF_REF/dotfiles"

# dotfiles proper
if [[ -z "${NODOT+x}" ]]; then
  mkdir -p "$HOME/.config/nvim"
  fetch "$RAWDOTS/bashrc" > "$HOME/.bashrc"
  fetch "$RAWDOTS/gitconfig" > "$HOME/.gitconfig"
  fetch "$RAWDOTS/nvim.lua" > "$HOME/.config/nvim/init.lua"
fi

# local binaries
if [[ -z "${NOBIN+x}" ]]; then
  mkdir -p "$HOME/.local/bin"
  for url in "junegunn/fzf/releases/download/v$FZF_VERSION/fzf-$FZF_VERSION-linux_amd64.tar.gz" \
             "sharkdp/fd/releases/download/v$FD_VERSION/fd-v$FD_VERSION-x86_64-unknown-linux-gnu.tar.gz" \
             "burntsushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-x86_64-unknown-linux-musl.tar.gz"
  do
    fetch "https://github.com/$url" | tar -xz -C "$TMPDIR"
  done

  for bin in fzf fd rg; do
    find "$TMPDIR" -type f -name "$bin" -executable -exec cp {} "$HOME/.local/bin" \;
  done
fi

# nvim and plugins
if [[ -z "${NOVIM+x}" ]]; then
  mkdir -p "$HOME/.local/share/nvim/site/pack/core/start"
  fetch "$RAWDOTS/nvim-pack-lock.json" > "$TMPDIR/nvim-pack-lock.json"
  fetch "https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64" |
    install -m 755 /dev/stdin "$TMPDIR/jq"

  "$TMPDIR/jq" -r '.plugins[] | "\(.src) \(.rev)"' "$TMPDIR/nvim-pack-lock.json" |
    while read -r src rev; do
      fetch "$src/archive/$rev.tar.gz" | tar -xz -C "$HOME/.local/share/nvim/site/pack/core/start"
      if [[ "$src" == "https://github.com/saghen/blink.cmp" ]]; then
        mkdir -p "$TMPDIR/lib"
        fetch "$src/releases/download/v$BLINK_VERSION/x86_64-unknown-linux-gnu.so" > \
          "$TMPDIR/lib/libblink_cmp_fuzzy.so"
        cp -r "$TMPDIR/lib" "$HOME/.local/share/nvim/site/pack/core/start/blink.cmp-$rev"
      fi
    done

  if [[ -z "${NOBIN+x}" ]]; then
    mkdir -p "$HOME/.local/opt"
    fetch "https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/nvim-linux-x86_64.tar.gz" |
      tar -xz -C "$HOME/.local/opt"
    ln -s "../opt/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin"
  fi

  # treesitter grammars
  if command -v nvim &>/dev/null || [[ -x "$HOME/.local/bin/nvim" ]]; then
    fetch "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz" |
      gzip -d | install -m 755 /dev/stdin "$TMPDIR/tree-sitter"

    PATH="$HOME/.local/bin:$TMPDIR:$PATH" \
      nvim --headless '+lua
      local patterns = vim.tbl_map(function(autocmd)
        return autocmd.pattern
      end, vim.api.nvim_get_autocmds({ group = "treesitter-highlight" }))
      require("nvim-treesitter").install(patterns):wait(60000)
      ' +qa
  fi
fi
