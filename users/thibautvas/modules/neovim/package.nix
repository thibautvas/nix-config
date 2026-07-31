{
  pkgs,
  unstablePkgs,
  dotfiles,
  wrapGit,
  ...
}:

let
  inherit (pkgs) lib;

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

  lspWrapped.extraPkgs = with pkgs; [
    unstablePkgs.ty
    unstablePkgs.ruff
    nixd
    nixfmt
    lua-language-server
  ];

  gitWrapped = {
    extraPkgs = [ pkgs.gitMinimal ];
    runtimeScript = ''
      git config user.name &>/dev/null ||
        export GIT_AUTHOR_NAME='placeholder' \
               GIT_COMMITTER_NAME='placeholder'
      git config user.email &>/dev/null ||
        export GIT_AUTHOR_EMAIL='place@holder.com' \
               GIT_COMMITTER_EMAIL='place@holder.com'
    '';
  };

  wrapperArgs =
    let
      extraPkgs = lspWrapped.extraPkgs ++ lib.optionals wrapGit gitWrapped.extraPkgs;
      runtimeScripts = lib.optionalString wrapGit gitWrapped.runtimeScript;
    in
    [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath extraPkgs)
      "--run"
      runtimeScripts
    ];

in
pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
  inherit
    luaRcContent
    plugins
    wrapperArgs
    ;
}
