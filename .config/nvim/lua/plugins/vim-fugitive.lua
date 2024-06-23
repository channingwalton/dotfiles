-- stuff
return {
  "tpope/vim-fugitive",
  keys = {
    { "<leader>gd", "<cmd>Git difftool<cr>", desc = "git difftool" },
    { "<leader>gm", "<cmd>Git mergetool<cr>", desc = "git mergetool" },
  },
}
