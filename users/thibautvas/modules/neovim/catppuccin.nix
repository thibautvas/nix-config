{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.catppuccin-nvim ];
    extraLuaConfig = ''
      require("catppuccin").setup({
        flavour = "mocha",
        term_colors = true,
        transparent_background = true,
        float = { transparent = true },
      })

      vim.cmd.colorscheme("catppuccin")
    '';
  };
}
