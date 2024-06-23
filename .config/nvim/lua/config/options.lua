-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Disable virtual_text since it's redundant due to lsp_lines.
vim.opt.cursorline = false
vim.opt.confirm = false
vim.opt.spell = false
vim.opt.spelllang = { "en_gb" }
vim.opt.scrolloff = 10
vim.opt.linebreak = true

-- This is for the Obsidian plugin https://github.com/epwalsh/obsidian.nvim/issues/286
vim.opt.conceallevel = 2
