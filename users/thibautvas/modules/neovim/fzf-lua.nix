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
      vim.keymap.set("n", "<leader>fg", fl.live_grep_native, { desc = "FzfLua live grep" })

      local work_dir = vim.fn.getenv("WORK_DIR")
      vim.keymap.set("n", "<leader>fa", function()
        fl.files { cwd = work_dir }
      end, { desc = "FzfLua WORK_DIR files" })

      vim.keymap.set("n", "<leader>fp", function()
        fl.fzf_exec("fd -t d -d 1 -L --base-directory " .. work_dir, {
          winopts = { title = " Projects " },
          actions = {
            ["default"] = function(selected)
              if selected[1] then
                local dir = table.concat({
                  work_dir,
                  vim.fn.fnameescape(selected[1])
                }, "/")
                vim.cmd("cd " .. dir)
              end
            end,
          },
        })
      end, { desc = "FzfLua change directory" })
    '';
  };
}
