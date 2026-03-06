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
      vim.highlight.priorities.semantic_tokens = 99
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

  xdg.configFile =
    let
      injections = {
        python = ''
          ;; extends
          (string
            (string_content) @injection.content
              (#vim-match? @injection.content "^\w*select|from|left join|inner join|where.*$")
              (#set! injection.language "sql"))
        '';
        nix = ''
          ;; extends
          ((binding
              attrpath: (attrpath) @_path
              expression: (indented_string_expression
                (string_fragment) @injection.content))
           (#match? @_path "extraLuaConfig")
           (#set! injection.language "lua"))
        '';
      };
    in
    lib.mapAttrs' (
      lang: content: lib.nameValuePair "nvim/queries/${lang}/injections.scm" { text = content; }
    ) injections;
}
