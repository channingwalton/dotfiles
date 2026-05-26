return {
  "unisonweb/unison",
  branch = "trunk",
  ft = "unison",
  dependencies = { "neovim/nvim-lspconfig" },
  config = function(plugin)
    vim.opt.rtp:append(plugin.dir .. "/editor-support/vim")
    require("lazy.core.loader").packadd(plugin.dir .. "/editor-support/vim")
    vim.lsp.enable("unison")
  end,
  init = function(plugin)
    require("lazy.core.loader").ftdetect(plugin.dir .. "/editor-support/vim")
  end,
}
