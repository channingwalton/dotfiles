-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- remap delete
vim.keymap.set("n", "dd", '"ddd', { desc = "send latest delete to d register" })
vim.keymap.set("n", "x", '"_x', { desc = "send char deletes to black hole, not worth saving" })

-- DAP keybindings (defined globally so they work without LSP)
vim.keymap.set("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<F5>", function() require("dap").continue() end, { desc = "Continue" })
vim.keymap.set("n", "<F10>", function() require("dap").step_over() end, { desc = "Step Over" })
vim.keymap.set("n", "<F11>", function() require("dap").step_into() end, { desc = "Step Into" })
vim.keymap.set("n", "<S-F11>", function() require("dap").step_out() end, { desc = "Step Out" })
vim.keymap.set("n", "<C-F8>", function() require("dap").run_to_cursor() end, { desc = "Run to Cursor" })

-- git conflicts picker (migrated from fzf-lua)
vim.keymap.set("n", "<leader>gx", function()
  local conflicts = vim.fn.systemlist("git diff --name-only --diff-filter=U --relative")
  if #conflicts == 0 or (conflicts[1] and conflicts[1]:match("^fatal")) then
    vim.notify("No merge conflicts found", vim.log.levels.INFO)
    return
  end
  local ok, snacks = pcall(function() return Snacks end)
  if not ok or not snacks then
    vim.notify("Snacks not available", vim.log.levels.WARN)
    return
  end
  snacks.picker.pick({
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
