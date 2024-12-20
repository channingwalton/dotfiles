-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("Change_Illuminate", { clear = true }),
  callback = function()
    vim.cmd([[hi IlluminatedWordText cterm=underline gui=undercurl]])
    vim.cmd([[hi IlluminatedWordRead cterm=underline gui=undercurl]])
    vim.cmd([[hi IlluminatedWordWrite cterm=underline gui=undercurl]])
  end,
  desc = "Change Illuminate Highlights",
})
