return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "Notes",
        path = "~/Documents/Notes/",
      },
    },
    note_id_func = function(title)
      return title
    end,
    note_frontmatter_func = function(note)
      return {}
    end,
    use_advanced_uri = true,
    open_app_foreground = true,
    attachments = {
      img_folder = "Attachments",
    },
    follow_url_func = function(url)
      -- Open the URL in the default web browser.
      vim.fn.jobstart({ "open", url }) -- Mac OS
      -- vim.fn.jobstart({"xdg-open", url})  -- linux
    end,
    daily_notes = {
      folder = "Journal/Daily Notes",
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      template = nil,
    },
  },

  keys = {
    { "<leader>o", desc = "Obsidian" },
    { "<leader>oo", "<cmd>ObsidianOpen<CR>", desc = "Open in Obsidian" },
    { "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", desc = "Quick switch" },
    { "<leader>of", "<cmd>ObsidianFollowLink<CR>", desc = "Follow link" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<CR>", desc = "Backlinks" },
  },
}
