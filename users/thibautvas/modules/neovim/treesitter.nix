{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (p: [ p.lua p.bash p.python p.sql ]))
      nvim-treesitter-textobjects
    ];

    extraLuaConfig = ''
      opts = {
        auto_install = false,
        highlight = { enable = true, additional_vim_regex_highlighting = { "markdown" } },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
            }
          }
        }
      }
      require("nvim-treesitter.configs").setup(opts)
    '';
  };
}
