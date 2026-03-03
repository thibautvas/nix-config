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
      rev = "92284065f53cd4f21d87e693dbf194def4c7c9e1";
      sha256 = "sha256-BO0YKXLRCn/QdJ9Iw4VdYPriYEGBKdZ3i1puWIfBAZg=";
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

      local stage_range = function(mode)
        if mode == "v" then
          return { vim.fn.line("."), vim.fn.line("v") }
        end
      end

      for _, mode in ipairs({ "n", "v" }) do
        vim.keymap.set(mode, "<leader>hf", function()
          gs.stage_hunk(stage_range(mode), {}, function()
            gu.extend()
          end)
        end, { desc = "Gitsigns stage and Gitutils extend" })
      end

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
