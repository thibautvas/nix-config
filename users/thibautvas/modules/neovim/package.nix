{
  pkgs,
  unstablePkgs,
  gitutils-nvim,
  ...
}:

let
  inherit (pkgs) lib;

  configs =
    let
      imp =
        path:
        import path {
          inherit
            lib
            pkgs
            unstablePkgs
            gitutils-nvim
            ;
        };
    in
    map imp [
      ./settings.nix
      ./blink.nix
      ./fzf-lua.nix
      ./gitsigns.nix
      ./gitutils.nix
      ./image.nix
      ./kanagawa.nix
      ./lsp.nix
      ./oil.nix
      ./treesitter.nix
    ];

  luaRcContent = lib.concatMapStringsSep "\n" (c: c.extraLuaConfig) configs;
  plugins = lib.concatMap (c: c.plugins or [ ]) configs;
  wrapperArgs =
    let
      extraPackages = lib.concatMap (c: c.extraPackages or [ ]) configs;
    in
    lib.optionals (extraPackages != [ ]) [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath extraPackages)
    ];

in
pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
  inherit
    luaRcContent
    plugins
    wrapperArgs
    ;
}
