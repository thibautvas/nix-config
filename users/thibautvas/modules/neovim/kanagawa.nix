{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.kanagawa-nvim ];
    extraLuaConfig = ''
      require("kanagawa").setup({
        transparent = true,
        statementStyle = { bold = false },
        overrides = function()
          local t = {}
          for _, key in ipairs({
            "ModeMsg",
            "CursorLineNr",
            "Boolean",
            "@keyword.operator",
            "@string.escape",
          }) do
            t[key] = { bold = false }
          end
          return t
        end,
      })

      vim.cmd.colorscheme("kanagawa")
    '';
  };
}
