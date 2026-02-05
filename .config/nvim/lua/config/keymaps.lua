-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- remap delete
vim.keymap.set("n", "dd", '"ddd', { desc = "send latest delete to d register" })
vim.keymap.set("n", "x", '"_x', { desc = "send char deletes to black hole, not worth saving" })

-- git conflicts picker (migrated from fzf-lua)
vim.keymap.set("n", "<leader>gx", function()
  local conflicts = vim.fn.systemlist("git diff --name-only --diff-filter=U --relative")
  if #conflicts == 0 or (conflicts[1] and conflicts[1]:match("^fatal")) then
    vim.notify("No merge conflicts found", vim.log.levels.INFO)
    return
  end
  Snacks.picker.pick({
    title = "Conflicts",
    items = vim.tbl_map(function(f)
      return { text = f, file = f }
    end, conflicts),
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.cmd("edit " .. item.file)
      end
    end,
  })
end, { desc = "Conflicts" })
