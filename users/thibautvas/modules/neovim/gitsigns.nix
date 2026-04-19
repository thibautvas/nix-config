{
  pkgs,
  ...
}:

{
  plugins = [ pkgs.vimPlugins.gitsigns-nvim ];
  extraLuaConfig = ''
    local gs = require("gitsigns")
    gs.setup()

    for dir, keymap in pairs({
      next = "<M-h>",
      prev = "<M-H>",
    }) do
      vim.keymap.set({ "n", "v" }, keymap, function()
        gs.nav_hunk(dir, { target = "all" }, function()
          vim.cmd("norm! zz")
        end)
      end, { desc = "Gitsigns " .. dir .. " hunk" })
    end

    for action, keymap in pairs({
      stage = "<leader>ha",
      reset = "<leader>hr",
    }) do
      vim.keymap.set("n", keymap, gs[action .. "_hunk"], {
        desc = "Gitsigns " .. action .. " hunk",
      })
      vim.keymap.set("v", keymap, function()
        gs[action .. "_hunk"]({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Gitsigns " .. action .. " hunk (visual)" })
    end

    vim.keymap.set("n", "<leader>hd", gs.preview_hunk_inline, { desc = "Gitsigns diff hunk" })

    vim.keymap.set({ "o", "x" }, "ih", gs.select_hunk, { desc = "Gitsigns select hunk" })
  '';
}
