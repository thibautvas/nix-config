{
  config,
  lib,
  pkgs,
  flakes,
  ...
}:

let
  gitutils-nvim = flakes.gitutils-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default;

in
{
  programs.neovim = {
    plugins = [ gitutils-nvim ];
    extraLuaConfig = ''
      local gu = require("gitutils")
      gu.setup()

      vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
        pattern = "*",
        callback = require("gitutils.helpers").refresh_head,
      })

      vim.opt.rulerformat = "%50(%{g:gitutils_head}%= %l,%c%)"

      vim.keymap.set("n", "<leader>hc", gu.commit, { desc = "Gitutils commit" })
      vim.keymap.set("n", "<leader>he", gu.extend, { desc = "Gitutils extend" })
      vim.keymap.set("n", "<leader>hb", gu.checkout, { desc = "Gitutils checkout" })
      vim.keymap.set("n", "<leader>hx", gu.rebase, { desc = "Gitutils interactive rebase" })
      vim.keymap.set("n", "<leader>hv", gu.continue, { desc = "Gitutils rebase continue" })

      vim.keymap.set("n", "<leader>hf", function()
        gs.stage_hunk(nil, {}, gu.extend)
      end, { desc = "Gitsigns stage and Gitutils extend" })
      vim.keymap.set("v", "<leader>hf", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }, {}, gu.extend)
      end, { desc = "Gitsigns stage and Gitutils extend" })

      vim.keymap.set("n", "<leader>ht", gu.diffthis, { desc = "Gitutils diff buffer" })
      vim.keymap.set("n", "<leader>hg", gu.diff, { desc = "Gitutils diff repo" })
      vim.keymap.set("n", "]g", function()
        gu.qf_diff("next")
      end, { desc = "Gitutils next diff" })
      vim.keymap.set("n", "[g", function()
        gu.qf_diff("prev")
      end, { desc = "Gitutils prev diff" })
    '';
  };
}
