{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.fzf-lua ];
    extraLuaConfig = ''
      local fl = require("fzf-lua")
      fl.setup({
        fzf_opts = { ["--layout"] = "default" },
        winopts = {
          scrollbar = { hidden = true },
        },
        buffers = { previewer = false },
        files = {
          cwd_prompt = false,
          previewer = false,
        },
        keymap = {
          fzf = { ["ctrl-q"] = "select-all+accept" },
        },
      })

      vim.keymap.set("n", "<leader>fd", fl.files, { desc = "FzfLua files" })
      vim.keymap.set("n", "<leader>ff", fl.buffers, { desc = "FzfLua buffers" })
      vim.keymap.set("n", "<leader>fs", fl.git_status, { desc = "FzfLua git status" })
      vim.keymap.set("n", "<leader>fa", function()
        fl.files { cwd = vim.fn.getenv("WORK_DIR") }
      end,
      { desc = "FzfLua WORK_DIR files" })
      vim.keymap.set("n", "<leader>fg", fl.live_grep_native, { desc = "FzfLua live grep" })
    '';
  };
}
