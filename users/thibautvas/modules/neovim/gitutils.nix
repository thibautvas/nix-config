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
      rev = "e4293f895636a204f6e31f8a7a0f4f2283a127bb";
      sha256 = "sha256-5svD178rLfGM8GkZZ398VWFcwRfCDob2/q480nMHGPs=";
    };
  };
in
{
  programs.neovim = {
    plugins = [ gitutils-nvim ];
    extraLuaConfig = ''
      local gu = require("gitutils")
      require("gitutils.helpers").refresh_head()

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
    '';
  };
}
