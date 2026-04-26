{
  pkgs,
  ...
}:

{
  plugins = [ pkgs.vimPlugins.none-ls-nvim ];
  extraPackages = with pkgs; [
    ty
    ruff
    nixd
    nixfmt
    sqlfluff
    lua-language-server
  ];
  extraLuaConfig = ''
    vim.diagnostic.config({ virtual_text = true })

    for name, config in pairs({
      ty = {
        cmd = { "ty", "server" },
        filetypes = { "python" },
      },
      ruff = {
        cmd = { "ruff", "server" },
        filetypes = { "python" },
      },
      nixd = {
        cmd = { "nixd" },
        filetypes = { "nix" },
      },
      lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        settings = {
          Lua = {
            format = { enable = true },
          },
        },
      },
    }) do
      vim.lsp.config(name, config)
      vim.lsp.enable(name)
    end

    local nls = require("null-ls")
    nls.setup({
      sources = {
        nls.builtins.formatting.sqlfluff.with({
          extra_args = { "--dialect", "vertica" },
        }),
        nls.builtins.diagnostics.sqlfluff.with({
          extra_args = { "--dialect", "vertica" },
        }),
      },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client.server_capabilities.documentFormattingProvider then
          return
        end
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = vim.api.nvim_create_augroup("LspFormat." .. args.buf, { clear = true }),
          buffer = args.buf,
          callback = function()
            vim.lsp.buf.format({
              bufnr = args.buf,
              id = client.id,
            })
          end,
        })
      end,
    })
  '';
}
