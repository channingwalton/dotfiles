return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>T", desc = "Telescope" },
    {
      "<leader>ff",
      "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<cr>",
      desc = "Find Files inc. hidden",
    },
    {
      "<leader>sg",
      "<cmd>lua require('telescope.builtin').live_grep({additional_args = {'--hidden'}})<cr>",
      desc = "rg inc. hidden",
    },
  },

  opts = function(_, opts)
    if vim.g.neovide or vim.g.gui_vimr then
      opts.defaults = {
        winblend = 20,
      }
    end
  end,
}
