return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
    keys = {
      { "<leader>ct", "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm (float)" },
      { "<leader>ctt", "<cmd>ToggleTerm direction=vertical size=50<cr>", desc = "ToggleTerm (vertical)" },
    },
  },
}
