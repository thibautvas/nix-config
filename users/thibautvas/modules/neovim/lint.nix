{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.sqlfluff ];

  programs.neovim = {
    plugins = [ pkgs.vimPlugins.nvim-lint ];
    extraLuaConfig = ''
      require("lint").linters_by_ft = {
        sql = { "sqlfluff" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        pattern = "*.sql",
        callback = function()
          require("lint").try_lint()
        end,
      })
    '';
  };
}
