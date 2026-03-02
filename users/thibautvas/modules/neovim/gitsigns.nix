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

      local nav_hunk = function(keymap, dir)
        vim.keymap.set("n", keymap, function()
          gs.nav_hunk(dir, { target = "all" }, function()
            vim.cmd("norm! zz")
          end)
        end, { desc = "Gitsigns " .. dir .. " hunk" })
      end
      nav_hunk("<M-h>", "next")
      nav_hunk("<M-H>", "prev")

      local hunk_action = function(keymap, action)
        vim.keymap.set("n", keymap, gs[action .. "_hunk"], {
          desc = "Gitsigns " .. action .. " hunk"
        })
        vim.keymap.set("v", keymap, function()
          gs[action .. "_hunk"]({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Gitsigns " .. action .. " hunk (visual)" })
      end
      hunk_action("<leader>ha", "stage")
      hunk_action("<leader>hr", "reset")

      vim.keymap.set("n", "<leader>hd", gs.preview_hunk_inline, { desc = "Gitsigns diff hunk" })
      vim.keymap.set("n", "<leader>ht", function()
        local log_5 = vim.fn.system({ "git", "log", "--reverse", "-5", "--pretty=format:%h %s%d" })
        vim.ui.input({ prompt = log_5 .. "\nDiff against: " }, function(hash)
          if not hash or hash == "" then return end
          gs.diffthis(hash, {
            vertical = true,
            split = "belowright",
          })
        end)
      end, { desc = "Gitsigns diff file" })
    '';
  };
}
