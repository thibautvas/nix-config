{ config, lib, pkgs, ... }:

{
  programs.neovim.extraLuaConfig = ''
    vim.opt.updatetime = 250
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
    vim.opt.shiftwidth = 4
    vim.opt.inccommand = "split"
    vim.opt.undofile = true
    vim.opt.ignorecase = true
    vim.opt.smartcase = true

    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "yank to system clipboard" })
    vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "half page down and center" })
    vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "half page up and center" })
    vim.keymap.set("n", "n", "nzzzv", { desc = "next result and center" })
    vim.keymap.set("n", "N", "Nzzzv", { desc = "previous result and center" })
    vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<CR>", { desc = "clear higlight" })
  '';
}
