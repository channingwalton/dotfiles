return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
    keys = {
      { "<leader>ct", desc = "ToggleTerm" },
      { "<leader>ctt", "<cmd>ToggleTerm direction=vertical size=50<cr>", desc = "Vertical" },
    },
  },
}
