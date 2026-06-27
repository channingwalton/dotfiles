-- https://www.lazyvim.org/plugins/lsp#nvim-lspconfig

return {
  -- Main LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
    keys = {
      -- LSP commands (gd/gr/gI/<leader>sd are handled by LazyVim snacks_picker defaults)
      { "<leader>ml", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "Codelens run" },
      { "<leader>mo", "<cmd>Outline<CR>", desc = "Outline" },
      { "<leader>ms", "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "Signature" },
      {
        "<leader>mi",
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end,
        desc = "Toggle Inlay Hints",
      },
    },
  },

  -- LSP Saga for enhanced LSP UI
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    opts = {
      ui = {
        title = false,
        colors = {
          normal_bg = "none",
          title_bg = "none",
        },
      },
      outline = {
        keys = {
          expand_or_jump = "<cr>",
        },
      },
      finder = {
        keys = {
          vsplit = "v",
          split = "s",
          quit = { "q", "<esc>" },
          edit = { "<cr>" },
          close_in_preview = "q",
          expand_or_jump = "<CR>",
        },
      },
      definition = {
        edit = "<cr>",
        vsplit = "<C-v>",
        split = "<C-s>",
        tabe = "<C-t>",
      },
      lightbulb = {
        enable = false,
      },
      symbol_in_winbar = {
        enable = true,
        color_mode = true,
      },
    },
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      -- LSP Saga Actions
      { "<leader>ma", "<cmd>Lspsaga code_action<CR>", desc = "Code action" },
      { "<leader>mh", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover docs" },
      { "<leader>mf", "<cmd>Lspsaga finder<CR>", desc = "Find" },
      { "<leader>mp", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek" },
      { "<leader>mr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
      { "<leader>mI", "<cmd>Lspsaga incoming_calls<CR>", desc = "Incoming calls" },
      { "<leader>mO", "<cmd>Lspsaga outgoing_calls<CR>", desc = "Outgoing calls" },
      { "<leader>mn", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Diagnostic Next" },
    },
  },

  -- Enhanced LSP diagnostics display
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    keys = {
      {
        "<leader>cL",
        function()
          require("lsp_lines").toggle()
        end,
        desc = "Toggle lsp_lines",
      },
    },
    config = function()
      require("lsp_lines").setup()
      -- Disable virtual_text since it's redundant due to lsp_lines
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
