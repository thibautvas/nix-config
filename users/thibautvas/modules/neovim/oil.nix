{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.oil-git-status-nvim ];
    extraLuaConfig = ''
      opts = {
        win_options = { signcolumn = "yes:2" },
        view_options = { show_hidden = true },
        skip_confirm_for_simple_edits = true,
      }
      require("oil").setup(opts)

      gs_opts = {
        show_ignored = false,
      }
      require("oil-git-status").setup(gs_opts)

      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil in parent directory" })
    '';
  };
}
