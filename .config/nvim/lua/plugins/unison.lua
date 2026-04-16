return {
  "unisonweb/unison",
  branch = "trunk",
  ft = "u",
  dependencies = { "neovim/nvim-lspconfig" },
  config = function(plugin)
    vim.opt.rtp:append(plugin.dir .. "/editor-support/vim")
    require("lazy.core.loader").packadd(plugin.dir .. "/editor-support/vim")
    require("lspconfig").unison.setup({})
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("unison_ft", { clear = true }),
      pattern = { "u" },
      callback = function()
        require("unison")
      end,
    })
  end,
  init = function(plugin)
    require("lazy.core.loader").ftdetect(plugin.dir .. "/editor-support/vim")
  end,
}
