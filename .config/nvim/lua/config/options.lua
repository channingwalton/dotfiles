-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Disable virtual_text since it's redundant due to lsp_lines.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.cursorline = false
vim.opt.spell = false
vim.opt.spelllang = { "en_gb" }
vim.opt.scrolloff = 10
vim.opt.linebreak = true
vim.o.timeoutlen = 300
