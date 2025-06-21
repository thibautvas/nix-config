{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.oil-git-status-nvim ];
    extraLuaConfig = ''
      require("oil").setup({
        win_options = { signcolumn = "yes:2" },
        view_options = { show_hidden = true },
        skip_confirm_for_simple_edits = true,
      })

      require("oil-git-status").setup({
        show_ignored = false,
      })

      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil in parent directory" })
    '';
  };
}
