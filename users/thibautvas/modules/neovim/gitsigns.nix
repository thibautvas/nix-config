{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.gitsigns-nvim ];
    extraLuaConfig = ''
      local gs = require("gitsigns")
      gs.setup()

      local nav_hunk = function(dir)
        gs.nav_hunk(dir)
        vim.defer_fn(function()
          vim.cmd("norm! zz")
        end, 10)
      end
      vim.keymap.set("n", "<M-h>", function()
        nav_hunk("next")
      end, { desc = "Gitsigns next hunk" })
      vim.keymap.set("n", "<M-H>", function()
        nav_hunk("prev")
      end, { desc = "Gitsigns previous hunk" })

      vim.keymap.set("n", "<leader>ha", gs.stage_hunk, { desc = "Gitsigns stage hunk" })
      vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Gitsigns reset hunk" })
      vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Gitsigns unstage hunk" })

      vim.keymap.set("n", "<leader>hd", gs.preview_hunk_inline, { desc = "Gitsigns diff hunk" })
      vim.keymap.set("n", "<leader>ht", function()
        gs.diffthis("HEAD", {
          vertical = true,
          split = "belowright",
        })
      end, { desc = "Gitsigns diff file" })
      vim.keymap.set("n", "<leader>hb", gs.blame, { desc = "Gitsigns blame file" })

      vim.keymap.set("n", "<leader>hg", function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
        local win_height = vim.o.lines - 2
        local win_width = vim.o.columns
        local height = math.floor(win_height * 0.9)
        local width = math.floor(win_width * 0.9)
        local row = math.floor((win_height - height) / 2)
        local col = math.floor((win_width - width) / 2)
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded"
        })
        vim.fn.termopen("lazygit", {
          on_exit = function()
            vim.api.nvim_win_close(win, true)
          end
        })
        vim.cmd("startinsert")
      end, { desc = "Lazygit in floating window" })
    '';
  };
}
