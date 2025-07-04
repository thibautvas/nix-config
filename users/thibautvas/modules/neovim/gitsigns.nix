{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.gitsigns-nvim ];
    extraLuaConfig = ''
      require("gitsigns").setup({
        current_line_blame_opts = { delay = 0 },
      })
      vim.api.nvim_set_hl(0, "GitSignsAddPreview", { bg = "#41483D" })
      vim.api.nvim_set_hl(0, "GitSignsDeletePreview", { bg = "#502D30" })

      local gs = package.loaded.gitsigns
      local async_center = function()
        vim.defer_fn(function()
          vim.cmd("norm! zz")
        end, 10)
      end

      vim.keymap.set("n", "<M-h>", function()
        gs.nav_hunk("next")
        async_center()
      end,
      { desc = "Gitsigns next hunk" })
      vim.keymap.set("n", "<M-H>", function()
        gs.nav_hunk("prev")
        async_center()
      end,
      { desc = "Gitsigns previous hunk" })
      vim.keymap.set("n", "<leader>hd", gs.preview_hunk, { desc = "Gitsigns preview hunk" })
      vim.keymap.set("n", "<leader>ha", gs.stage_hunk, { desc = "Gitsigns stage hunk" })
      vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Gitsigns unstage hunk" })
      vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Gitsigns reset hunk" })
      vim.keymap.set("n", "<leader>hb", gs.blame, { desc = "Gitsigns blame file" })
    '';
  };
}
