{ config, lib, pkgs, ... }:

let
  # lock ruff 0.6.8 for work projects
  oldPkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e0f477a570df7375172a08ddb9199c90853c63f0.tar.gz";
    sha256 = "sha256-2/wcpn7a8xEx/c1/ih1DHTyVLOUME7xLRfi0mOBT35s=";
  }) {
    inherit (pkgs) system;
  };

in {
  home.packages = [
    pkgs.pyright
    oldPkgs.ruff
  ];

  programs.neovim.extraLuaConfig = ''
    vim.lsp.config.pyright = {
      cmd = { "pyright-langserver", "--stdio" },
      filetypes = { "python" },
      root_markers = {
        "pyproject.toml",
        "setup.py",
        "requirements.txt",
      },
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
      on_init = function(client, initialize_result)
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
      root_markers = {
        "pyproject.toml",
        "setup.py",
        "requirements.txt",
      },
    }

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        local opts = { buffer = args.buf, noremap = true, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
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

    vim.lsp.enable({ "pyright", "ruff" })
    vim.diagnostic.config({ virtual_text = true })
  '';
}
