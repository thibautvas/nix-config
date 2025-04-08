{ config, pkgs, ... }:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.nvim-lspconfig ];
    extraLuaConfig = ''
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local lspconfig = require("lspconfig")

      local get_python_path = function(workspace)
        local python_bin = lspconfig.util.path.join(workspace, ".venv", "bin", "python")
        if lspconfig.util.path.is_file(python_bin) then
          return python_bin
        end
        return vim.fn.getenv("HOSTPDI")
      end

      lspconfig.pyright.setup {
        capabilities = capabilities,
        on_init = function(client)
          local workspace = client.config.root_dir or vim.fn.getenv("PWD")
          client.config.settings.python.pythonPath = get_python_path(workspace)
        end,
        root_dir = lspconfig.util.root_pattern(".git", "pyproject.toml", "setup.py", "requirements.txt"),
      }
      lspconfig.ruff.setup {}

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          local opts = { buffer = args.buf, noremap = true, silent = true }
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gn", vim.lsp.buf.rename, opts)

          if vim.bo.filetype == "python" and client.name == "ruff" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
              end
            })
          end
        end
      })
    '';
  };
}
