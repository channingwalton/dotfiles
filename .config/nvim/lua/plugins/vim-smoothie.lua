if vim.g.neovide then
  -- neovide smooth scrolls natively
  return {}
else
  return {
    {
      "folke/snacks.nvim",
      opts = {
        scroll = { enabled = true },
      },
    },
  }
end
