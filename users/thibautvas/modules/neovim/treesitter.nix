{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (p: [
        p.bash
        p.lua
        p.nix
        p.python
        p.sql
      ]))
      nvim-treesitter-textobjects
    ];
    extraLuaConfig = ''
      require("nvim-treesitter.configs").setup({
        auto_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "markdown" },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
            },
          },
        },
      })
    '';
  };

  xdg.configFile."nvim/queries/python/injections.scm".text = ''
    ;; extends
    (string
      (string_content) @injection.content
        (#vim-match? @injection.content "^\w*select|from|left join|inner join|where.*$")
        (#set! injection.language "sql"))
    (call
      function: (attribute attribute: (identifier) @id (#match? @id "execute|read_sql"))
      arguments: (argument_list
        (string (string_content) @injection.content (#set! injection.language "sql"))))
  '';
}
