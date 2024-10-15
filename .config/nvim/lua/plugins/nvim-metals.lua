return {
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      opts.sections = {
        lualine_c = { "filename", { "g:metals_status" } },
      }
    end,
  },
}
