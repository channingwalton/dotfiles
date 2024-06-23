return {
  "crusj/bookmarks.nvim",
  keys = {
    { "<leader>B", desc = "Bookmarks" },
    { "<leader>BB", "<cmd>lua require'bookmarks'.toggle_bookmarks()<cr>", desc = "Toggle bookmarks" },
    { "<leader>Bl", "<cmd>lua require'bookmarks'.add_bookmarks(false)<cr>", desc = "Add local bookmark" },
    { "<leader>Bg", "<cmd>lua require'bookmarks'.add_bookmarks(true)<cr>", desc = "Add global bookmark" },
    { "<leader>B<space>", "<cmd>Telescope bookmarks<cr>", desc = "Telescope" },
    {
      "<leader>Bd",
      "<cmd>lua require'bookmarks.list'.delete_on_virt()<cr>",
      desc = "Delete bookmark at virt text line",
    },
    {
      "<leader>Bs",
      "<cmd>lua require'bookmarks.list'.show_desc()<cr>",
      desc = "Show bookmark description",
    },
  },
  branch = "main",
  dependencies = { "nvim-web-devicons" },
  config = function()
    require("bookmarks").setup()
    require("telescope").load_extension("bookmarks")
  end,
}
