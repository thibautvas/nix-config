{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    pyright
    nixd
    nixfmt
  ];

  programs.neovim = {
    plugins = [ pkgs.vimPlugins.none-ls-nvim ];
    extraLuaConfig = ''
      local python_root_markers = {
        "pyproject.toml",
        "setup.py",
        "requirements.txt",
      }

      vim.lsp.config.pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = python_root_markers,
        settings = {
          pyright = {
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              diagnosticMode = "openFilesOnly",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
        on_init = function(client)
          local root_dir = client.config.root_dir or vim.fn.getcwd()
          local python_bin = root_dir .. "/.venv/bin/python"
          if vim.fn.executable(python_bin) == 1 then
            client.config.settings.python.pythonPath = python_bin
          end
        end,
      }

      vim.lsp.config.ruff = {
        cmd = { "ruff", "server" },
        filetypes = { "python" },
        root_markers = python_root_markers,
      }

      local builtins = require("null-ls.builtins")
      require("null-ls").setup({
        sources = {
          builtins.formatting.sqlfluff,
          builtins.diagnostics.sqlfluff,
        },
      })

      vim.lsp.config.nixd = {
        cmd = { "nixd" },
        filetypes = { "nix" },
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        pattern = { "*.py", "*.sql", "*.nix" },
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          if client.name == "ruff" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                vim.lsp.buf.code_action({
                  context = { only = { "source.fixAll" } },
                  apply = true,
                })
                vim.wait(10) -- temp: async code action
              end,
            })
          end

          if client.name == "nixd" or client.name == "null-ls" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
              end,
            })
          end
        end,
      })

      vim.lsp.enable({ "pyright", "ruff", "nixd" })
      vim.diagnostic.config({ virtual_text = true })
    '';
  };
}
