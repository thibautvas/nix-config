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
      local git_log = function(lb, format)
        return vim.fn.system({ "git", "log", "-n" .. lb, "--pretty=format:" .. format })
      end

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
        vim.ui.input({ prompt = git_log(5, "%h %s%d") .. "\nDiff against: " }, function(hash)
          if not hash or hash == "" then return end
          gs.diffthis(hash, {
            vertical = true,
            split = "belowright",
          })
        end)
      end, { desc = "Gitsigns diff file" })

      vim.keymap.set("n", "<leader>hc", function()
        vim.ui.input({ prompt = "Commit message: " }, function(msg)
          vim.fn.system({ "git", "commit", "-m", msg })
          vim.notify("Committed: " .. msg)
        end)
      end, { desc = "Git commit" })

      vim.keymap.set("n", "<leader>he", function()
        vim.fn.system({ "git", "commit", "--amend", "--no-edit" })
        local msg = git_log(1, "%s")
        vim.notify("Extended: " .. msg)
      end, { desc = "Git extend" })

      vim.keymap.set("n", "<leader>hb", function()
        vim.ui.input({ prompt = git_log(5, "%h %s%d") .. "\nCheckout: " }, function(hash)
          if not hash or hash == "" then return end
          vim.fn.system({ "git", "checkout", hash })
          vim.cmd("checktime")
          local msg = git_log(1, "%D: %s")
          vim.cmd("redraw")
          vim.notify("Switched to " .. msg)
        end)
      end, { desc = "Git checkout" })
    '';
  };
}
