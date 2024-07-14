-- This is for Cody, https://github.com/sourcegraph/sg.nvim
return {
  {
    "sourcegraph/sg.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      enable_cody = true,
      accept_tos = true,
      download_binaries = true,
    },
    config = function(opts)
      require("sg").setup(opts)
    end,
  },
}
