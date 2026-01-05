{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    ty
    ruff
    nixd
    nixfmt
  ];

  programs.neovim = {
    plugins = [ pkgs.vimPlugins.none-ls-nvim ];
    extraLuaConfig = ''
      vim.lsp.config.ty = {
        cmd = { "ty", "server" },
        filetypes = { "python" },
      }

      vim.lsp.config.ruff = {
        cmd = { "ruff", "server" },
        filetypes = { "python" },
      }

      local nls = require("null-ls")
      nls.setup({
        sources = {
          nls.builtins.formatting.sqlfluff,
          nls.builtins.diagnostics.sqlfluff,
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
          if not client.server_capabilities.documentFormattingProvider then return end

          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
            end,
          })
        end,
      })

      vim.lsp.enable({ "ty", "ruff", "nixd" })
      vim.diagnostic.config({ virtual_text = true })
    '';
  };
}
