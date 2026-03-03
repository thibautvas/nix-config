{
  config,
  lib,
  pkgs,
  ...
}:

let
  gitutils-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "gitutils-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "thibautvas";
      repo = "gitutils.nvim";
      rev = "eb97494ea1dd6f82a4e1b86a7ceac7186cb6304e";
      sha256 = "sha256-8c6p6ftratHBfdVXtQlrT1OOlSjz15Ez0dmaqh75mD8=";
    };
  };
in
{
  programs.neovim = {
    plugins = [ gitutils-nvim ];
    extraLuaConfig = ''
      local gu = require("gitutils")
      gu.setup()

      vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
        pattern = "*",
        callback = require("gitutils.helpers").refresh_head
      })

      vim.opt.rulerformat = '%66(%{g:gitutils_head}%= %l,%c%)'

      vim.keymap.set("n", "<leader>hc", gu.commit, { desc = "Gitutils commit" })
      vim.keymap.set("n", "<leader>he", gu.extend, { desc = "Gitutils extend" })
      vim.keymap.set("n", "<leader>hb", gu.checkout, { desc = "Gitutils checkout" })
      vim.keymap.set("n", "<leader>hx", gu.rebase, { desc = "Gitutils interactive rebase" })
      vim.keymap.set("n", "<leader>hv", gu.continue, { desc = "Gitutils rebase continue" })

      vim.keymap.set("n", "<leader>hf", function()
        gs.stage_hunk(nil, {}, function()
          gu.extend()
        end)
      end, { desc = "Gitsigns stage and Gitutils extend" })

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
