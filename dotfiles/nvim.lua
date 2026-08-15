---@diagnostic disable: undefined-global

vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.guicursor = ""
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.wrap = false
vim.opt.signcolumn = "yes"
vim.opt.laststatus = 0
vim.opt.scrolloff = 10
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.shiftwidth = 4
  end,
})
vim.opt.inccommand = "split"
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "half page down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "half page up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "next result and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "previous result and center" })
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "clear highlights" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "yank to system clipboard" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "escape out of terminal mode" })


-- lsp
vim.diagnostic.config({ virtual_text = true })
local servers = {
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
}
if vim.lsp.config then
  for name, config in pairs(servers) do
    vim.lsp.config(name, config)
    vim.lsp.enable(name)
  end
end

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


-- treesitter
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "bash", "nix", "python", "sql" },
  group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
  callback = function()
    pcall(vim.treesitter.start)
  end,
})


-- plugins
local function init(name, fn)
  local ok, mod = pcall(require, name)
  if ok then
    fn(mod)
  end
end


-- 0.12 experimental feature
init("vim._core.ui2", function(ui2)
  ui2.enable()
end)


-- nvim-treesitter-textobjects
init("nvim-treesitter-textobjects", function()
  for textobject, keymap in pairs({
    ["@function.inner"] = "if",
    ["@function.outer"] = "af",
  }) do
    vim.keymap.set({ "o", "x" }, keymap, function()
      require("nvim-treesitter-textobjects.select").select_textobject(textobject, "textobjects")
    end, { desc = "Treesitter select " .. textobject })
  end
end)


-- blink.cmp
init("blink.cmp", function(bc)
  bc.setup()
end)


-- fzf-lua
init("fzf-lua", function(fl)
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

  local work_dir = vim.env.WORK_DIR or vim.env.HOME .. "/repos"
  vim.keymap.set("n", "<leader>fa", function()
    fl.files({ cwd = work_dir })
  end, { desc = "FzfLua WORK_DIR files" })

  vim.keymap.set("n", "<leader>fp", function()
    fl.fzf_exec("fd -t d -H -L --base-directory " .. work_dir .. " '^\\.git$' -x dirname {}", {
      winopts = { title = " Projects " },
      actions = {
        ["default"] = function(selected)
          if selected[1] then
            local dir = table.concat({
              work_dir,
              vim.fn.fnameescape(selected[1]),
            }, "/")
            vim.cmd("cd " .. dir)
          end
        end,
      },
    })
  end, { desc = "FzfLua change directory" })
end)


-- gitsigns.nvim
init("gitsigns", function(gs)
  for dir, keymap in pairs({
    next = "<M-h>",
    prev = "<M-H>",
  }) do
    vim.keymap.set({ "n", "v" }, keymap, function()
      gs.nav_hunk(dir, { target = "all" }, function()
        vim.cmd("norm! zz")
      end)
    end, { desc = "Gitsigns " .. dir .. " hunk" })
  end

  for action, keymap in pairs({
    stage = "<leader>ha",
    reset = "<leader>hr",
  }) do
    vim.keymap.set("n", keymap, gs[action .. "_hunk"], {
      desc = "Gitsigns " .. action .. " hunk",
    })
    vim.keymap.set("v", keymap, function()
      gs[action .. "_hunk"]({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "Gitsigns " .. action .. " hunk (visual)" })
  end

  vim.keymap.set("n", "<leader>hd", gs.preview_hunk_inline, { desc = "Gitsigns diff hunk" })

  vim.keymap.set({ "o", "x" }, "ih", gs.select_hunk, { desc = "Gitsigns select hunk" })
end)


-- gitutils.nvim
init("gitutils", function(gu)
  gu.setup()

  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    pattern = "*",
    callback = require("gitutils.helpers").refresh_head,
  })

  vim.opt.rulerformat = "%50(%{g:gitutils_head}%= %l,%c%)"

  vim.keymap.set("n", "<leader>hc", gu.commit, { desc = "Gitutils commit" })
  vim.keymap.set("n", "<leader>he", gu.extend, { desc = "Gitutils extend" })
  vim.keymap.set("n", "<leader>hb", gu.checkout, { desc = "Gitutils checkout" })
  vim.keymap.set("n", "<leader>hx", gu.rebase, { desc = "Gitutils interactive rebase" })
  vim.keymap.set("n", "<leader>hv", gu.continue, { desc = "Gitutils rebase continue" })

  vim.keymap.set("n", "<leader>hf", function()
    require("gitsigns").stage_hunk(nil, {}, gu.extend)
  end, { desc = "Gitsigns stage and Gitutils extend" })
  vim.keymap.set("v", "<leader>hf", function()
    require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") }, {}, gu.extend)
  end, { desc = "Gitsigns stage and Gitutils extend" })

  vim.keymap.set("n", "<leader>ht", gu.diffthis, { desc = "Gitutils diff buffer" })
  vim.keymap.set("n", "<leader>hg", gu.diff, { desc = "Gitutils diff repo" })
  vim.keymap.set("n", "]g", function()
    gu.qf_diff("next")
  end, { desc = "Gitutils next diff" })
  vim.keymap.set("n", "[g", function()
    gu.qf_diff("prev")
  end, { desc = "Gitutils prev diff" })
end)


-- image.nvim
init("image", function(ig)
  ig.setup({ processor = "magick_rock" })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "image_nvim",
    callback = function()
      vim.opt_local.fillchars:append({ eob = " " })
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "fzf",
    callback = function()
      if #ig.get_images() > 0 then
        ig.clear()
      end
    end,
  })
end)


-- kanagawa.nvim
init("kanagawa", function(kw)
  kw.setup({
    transparent = true,
    statementStyle = { bold = false },
    overrides = function()
      local t = {}
      for _, key in ipairs({
        "ModeMsg",
        "CursorLineNr",
        "Boolean",
        "@keyword.operator",
        "@string.escape",
      }) do
        t[key] = { bold = false }
      end
      return t
    end,
  })

  vim.cmd.colorscheme("kanagawa")
end)


-- oil.nvim
init("oil", function(ol)
  ol.setup({
    view_options = { show_hidden = true },
    skip_confirm_for_simple_edits = true,
  })

  vim.keymap.set("n", "-", ol.open, { desc = "Oil in parent directory" })
end)
