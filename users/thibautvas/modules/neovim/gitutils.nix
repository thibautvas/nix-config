{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    extraLuaConfig = ''
      local gitutils_commit = function()
        vim.ui.input({ prompt = "Commit message: " }, function(msg)
          vim.fn.system({ "git", "commit", "-m", msg })
          vim.notify("Committed: " .. msg)
        end)
      end

      local gitutils_extend = function()
        vim.fn.system({ "git", "commit", "--amend", "--no-edit" })
        vim.notify("Extended: " .. git_log(1, "%s"))
      end

      local gitutils_checkout = function()
        vim.ui.input({ prompt = git_log(5, "%h %s%d") .. "\nCheckout: " }, function(hash)
          if not hash or hash == "" then return end
          vim.fn.system({ "git", "checkout", hash })
          if vim.v.shell_error == 0 then
            vim.cmd("checktime")
            vim.cmd("redraw")
            vim.notify("Switched to " .. git_log(1, "%D: %s"))
          else
            vim.notify("Git checkout failed", vim.log.levels.ERROR)
          end
        end)
      end

      local rebase_state = nil

      local gitutils_rebase = function()
        vim.ui.input({ prompt = git_log(5, "%h %s%d") .. "\nRebase from: " }, function(hash)
          if not hash or hash == "" then return end

          local server = vim.v.servername
          if not server or server == "" then return end

          local fifo = vim.fn.tempname()
          vim.fn.system({ "mkfifo", fifo })

          local script = vim.fn.tempname() .. ".sh"
          local f = assert(io.open(script, "w"))
          f:write(string.format(
            "#!/bin/sh\nnvim --server '%s' --remote \"$1\"\ncat '%s' > /dev/null\n",
          server, fifo))
          f:close()
          vim.fn.system({ "chmod", "+x", script })

          local env = {
            GIT_SEQUENCE_EDITOR = script,
            GIT_EDITOR = script,
          }

          rebase_state = { fifo = fifo, script = script, env = env }

          local au_id = vim.api.nvim_create_autocmd("BufUnload", {
            pattern = {
              "*/git-rebase-todo",
              "*/COMMIT_EDITMSG",
            },
            callback = function()
              vim.fn.jobstart({ "sh", "-c", "echo done > " .. vim.fn.shellescape(fifo) })
            end
          })

          vim.fn.jobstart({ "git", "rebase", "-i", hash }, {
            env = env,
            on_exit = function(_, code)
              vim.schedule(function()
                vim.cmd("checktime")

                local in_progress = vim.fn.isdirectory(".git/rebase-merge") == 1
                if in_progress then
                  vim.notify("Rebase in progress")
                else
                  vim.api.nvim_del_autocmd(au_id)
                  rebase_state = nil
                  if code == 0 then
                    vim.notify("Rebase done " .. git_log(1, "%D: %s"))
                  else
                    vim.notify("Rebase exited with code " .. code, vim.log.levels.ERROR)
                  end
                end
              end)
            end,
          })
        end)
      end

      local gitutils_continue = function()
        if rebase_state then
          vim.fn.jobstart({ "git", "rebase", "--continue" }, {
            env = rebase_state.env,
          })
        else
          vim.notify("No rebase in progress", vim.log.levels.WARN)
        end
      end

      local subcmds = {
        checkout = gitutils_checkout,
        commit = gitutils_commit,
        extend = gitutils_extend,
        rebase = gitutils_rebase,
        continue = gitutils_continue,
      }

      vim.api.nvim_create_user_command("Gitutils", function(opts)
        local sub = opts.args
        if subcmds[sub] then
          subcmds[sub]()
        else
          vim.notify("Gitutils: unknown subcommand '" .. sub .. "'", vim.log.levels.ERROR)
        end
      end, {
        nargs = 1,
        complete = function()
          return vim.tbl_keys(subcmds)
        end,
      })

      vim.keymap.set("n", "<leader>hc", gitutils_commit, { desc = "Git commit" })
      vim.keymap.set("n", "<leader>he", gitutils_extend, { desc = "Git extend" })
      vim.keymap.set("n", "<leader>hb", gitutils_checkout, { desc = "Git checkout" })
      vim.keymap.set("n", "<leader>hx", gitutils_rebase, { desc = "Git interactive rebase" })
      vim.keymap.set("n", "<leader>hv", gitutils_continue, { desc = "Git rebase continue" })

      vim.keymap.set("n", "<leader>hf", function()
        gs.stage_hunk()
        vim.defer_fn(function()
          gitutils_extend()
        end, 10)
      end, { desc = "Git stage and extend" })


      local head_commit = { hash = nil, title = nil }

      vim.api.nvim_create_autocmd("User", {
        pattern = "GitSignsUpdate",
        callback = function()
          local hash = vim.fn.system({ "git", "rev-parse", "--short", "HEAD" })
          if hash ~= head_commit.hash then
            head_commit.hash = hash
            head_commit.title = git_log(1, "%s")
          end
        end,
      })

      Get_head_commit = function()
        if vim.g.gitsigns_head then
          return head_commit.title .. " -> " .. vim.g.gitsigns_head
        else
          return ""
        end
      end

      vim.opt.rulerformat = '%66(%{v:lua.Get_head_commit()}%= %l,%c%)'
    '';
  };
}
