-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.cursorline = false
vim.opt.spell = false
vim.opt.spelllang = { "en_gb" }
vim.opt.spelloptions = "camel"
-- spell/*.spl is not tracked: rebuild it whenever its .add wordlist is newer (edited or pulled)
for _, add in ipairs(vim.fn.glob(vim.fn.stdpath("config") .. "/spell/*.add", false, true)) do
  if vim.fn.getftime(add) > vim.fn.getftime(add .. ".spl") then
    vim.cmd("silent mkspell! " .. vim.fn.fnameescape(add))
  end
end
vim.opt.scrolloff = 10
vim.opt.linebreak = true
vim.opt.timeoutlen = 300

vim.lsp.log.set_level(vim.log.levels.ERROR)
