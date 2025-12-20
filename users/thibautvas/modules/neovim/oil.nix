{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.oil-nvim ];
    extraLuaConfig = ''
      require("oil").setup({
        view_options = { show_hidden = true },
        skip_confirm_for_simple_edits = true,
      })

      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil in parent directory" })
    '';
  };
}
