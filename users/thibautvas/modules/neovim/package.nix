{
  pkgs,
  unstablePkgs,
  dotfiles,
  ...
}:

let
  luaRcContent = builtins.readFile "${dotfiles}/nvim/init.lua";
  plugins =
    let
      tsPlugins =
        p: with p; [
          bash
          nix
          python
          sql
        ];
    in
    with pkgs.vimPlugins;
    [
      (nvim-treesitter.withPlugins tsPlugins)
      nvim-treesitter-textobjects
      blink-cmp
      fzf-lua
      gitsigns-nvim
      gitutils-nvim
      image-nvim
      kanagawa-nvim
      oil-nvim
    ];
  wrapperArgs =
    let
      extraPkgs = with pkgs; [
        gitMinimal
        unstablePkgs.ty
        unstablePkgs.ruff
        nixd
        nixfmt
        lua-language-server
      ];
      gitEnvScript = ''
        export GIT_AUTHOR_NAME="$(git config user.name || echo 'placeholder')"
        export GIT_AUTHOR_EMAIL="$(git config user.email || echo 'place@holder.com')"
        export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
        export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
      '';
    in
    [
      "--prefix"
      "PATH"
      ":"
      (pkgs.lib.makeBinPath extraPkgs)
      "--run"
      gitEnvScript
    ];

in
pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
  inherit
    luaRcContent
    plugins
    wrapperArgs
    ;
}
