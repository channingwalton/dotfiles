-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- remap delete, unless a register is named ("add, "ax). With no register named, v:register
-- is the clipboard register for typed keys but '"' under :normal (:g/pat/normal dd).
local function register_named()
  local clipboard = vim.o.clipboard
  local default = clipboard:find("unnamedplus") and "+" or clipboard:find("unnamed") and "*" or '"'
  return vim.v.register ~= '"' and vim.v.register ~= default
end
vim.keymap.set("n", "dd", function()
  return register_named() and "dd" or '"ddd'
end, { expr = true, desc = "send latest delete to d register" })
vim.keymap.set("n", "x", function()
  return register_named() and "x" or '"_x'
end, { expr = true, desc = "send char deletes to black hole, not worth saving" })

-- zg adds the word and its plural. Lowercase spellfile entries match any capitalisation
-- except mixed case (PlantUML, UUIDs), which only matches an exact entry, so mixed-case
-- forms are added as-is too. zug removes every form zg added.
local function plural(word)
  local lower = vim.fn.tolower(word)
  if lower:match("s$") then
    return nil
  elseif vim.fn.toupper(word) == word then
    return word .. "s" -- acronyms: APIs, UUIDs
  elseif lower:match("[xz]$") or lower:match("[cs]h$") then
    return word .. "es"
  elseif lower:match("[^aeiou]y$") then
    return word:sub(1, -2) .. "ies"
  end
  return word .. "s"
end

local function spell_entries(word)
  local entries = {}
  for _, form in ipairs({ word, plural(word) }) do
    table.insert(entries, vim.fn.tolower(form))
    local rest = vim.fn.strcharpart(form, 1)
    if vim.fn.tolower(rest) ~= rest and vim.fn.toupper(form) ~= form then
      table.insert(entries, form)
    end
  end
  return entries
end

local function map_spell(lhs, command, desc)
  vim.keymap.set("n", lhs, function()
    local word = vim.fn.expand("<cword>")
    if word == "" then
      return
    end
    for _, entry in ipairs(spell_entries(word)) do
      vim.cmd[command](entry)
    end
  end, { desc = desc })
end
map_spell("zg", "spellgood", "Add word (any case + plural) to spellfile")
map_spell("zug", "spellundo", "Remove word (any case + plural) from spellfile")

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
        vim.cmd("edit " .. vim.fn.fnameescape(item.file))
      end
    end,
  })
end, { desc = "Conflicts" })
