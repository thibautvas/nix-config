{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.catppuccin-nvim ];
    extraLuaConfig = ''
      opts = {
        flavour = "mocha",
        term_colors = true,
        transparent_background = true
      }
      require("catppuccin").setup(opts)
      require("catppuccin").load()
    '';
  };
}
