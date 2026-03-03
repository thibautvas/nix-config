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
        vim.keymap.set({ "n", "v" }, keymap, function()
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

      vim.keymap.set({ "o", "x" }, "ih", "<Cmd>Gitsigns select_hunk<CR>")
    '';
  };
}
