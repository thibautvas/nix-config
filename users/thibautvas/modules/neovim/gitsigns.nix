{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.gitsigns-nvim ];
    extraLuaConfig = ''
      local gs = require("gitsigns")
      gs.setup()

      local nav_hunk = function(dir)
        gs.nav_hunk(dir, { target = "all" })
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

      vim.keymap.set("n", "<leader>hd", gs.preview_hunk_inline, { desc = "Gitsigns diff hunk" })
      vim.keymap.set("n", "<leader>ht", function()
        gs.diffthis("HEAD", {
          vertical = true,
          split = "belowright",
        })
      end, { desc = "Gitsigns diff file" })
      vim.keymap.set("n", "<leader>hb", gs.blame, { desc = "Gitsigns blame file" })

      vim.keymap.set("n", "<leader>hc", function()
        vim.ui.input({ prompt = "Commit message: " }, function(msg)
          vim.fn.system({ "git", "commit", "-m", msg })
          print("Committed: " .. msg)
        end)
      end, { desc = "Git commit" })

      vim.keymap.set("n", "<leader>he", function()
        vim.fn.system({ "git", "commit", "--amend", "--no-edit" })
        local msg = vim.fn.system({ "git", "log", "-n1", "--pretty=%B" })
        msg = vim.trim(msg)
        print("Extended: " .. msg)
      end, { desc = "Git extend" })
    '';
  };
}
