-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("n", "<leader>sR", "<cmd>FzfLua resume<cr>", { desc = "Resume" })

-- remap delete
vim.keymap.set("n", "dd", '"ddd', { desc = "send latest delete to d register" })
vim.keymap.set("n", "x", '"_x', { desc = "send char deletes to black hole, not worth saving" })
