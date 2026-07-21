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
        git
        unstablePkgs.ty
        unstablePkgs.ruff
        nixd
        nixfmt
        lua-language-server
      ];
    in
    [
      "--prefix"
      "PATH"
      ":"
      (pkgs.lib.makeBinPath extraPkgs)
    ];

in
pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
  inherit
    luaRcContent
    plugins
    wrapperArgs
    ;
}
