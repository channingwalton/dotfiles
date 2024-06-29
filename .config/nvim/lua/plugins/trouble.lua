return {
  "folke/trouble.nvim",
  opts = {
    warn_no_results = false, -- show a warning when there are no results
    open_no_results = true, -- open the trouble window when there are no results
  },
  keys = {
    {
      "<leader>xs",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>xd",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
  },
}
