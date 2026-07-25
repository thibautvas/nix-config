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
        git config user.name &>/dev/null ||
          export GIT_AUTHOR_NAME='placeholder' \
                 GIT_COMMITTER_NAME='placeholder'
        git config user.email &>/dev/null ||
          export GIT_AUTHOR_EMAIL='place@holder.com' \
                 GIT_COMMITTER_EMAIL='place@holder.com'
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
