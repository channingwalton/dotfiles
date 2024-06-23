return {
  {
    "SuperBo/fugit2.nvim",
    opts = {
      width = 70,
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
      {
        "chrisgrieser/nvim-tinygit", -- optional: for Github PR view
        dependencies = { "stevearc/dressing.nvim" },
      },
    },
    cmd = { "Fugit2", "Fugit2Graph" },
    keys = {
      { "<leader>F", desc = "Fugit" },
      { "<leader>FF", mode = "n", "<cmd>Fugit2<cr>", desc = "Fugit" },
    },
  },
  {
    -- optional: for diffview.nvim integration
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- lazy, only load diffview by these commands
    cmd = {
      "DiffviewFileHistory",
      "DiffviewOpen",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
    },
    keys = {
      { "<leader>FD", desc = "Diffview" },
      { "<leader>FDD", "<cmd>DiffviewOpen<cr>", desc = "Open" },
      { "<leader>FDC", "<cmd>DiffviewClose<cr>", desc = "Close" },
      { "<leader>FDH", "<cmd>DiffviewFileHistory<cr>", desc = "History" },
      { "<leader>FDR", "<cmd>DiffviewRefresh<cr>", desc = "Refresh" },
    },
  },
}
