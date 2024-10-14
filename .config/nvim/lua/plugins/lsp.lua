-- https://www.lazyvim.org/plugins/lsp#nvim-lspconfig

vim.lsp.set_log_level(vim.log.levels.ERROR)
vim.g.autoformat = true

vim.keymap.set("v", "<leader>ma", vim.lsp.buf.code_action)

return {
  {
    "nvimdev/lspsaga.nvim",
    lazy = false,
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        inlay_hints = {
          enabled = false,
        },
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
            expand_or_jump = "<>",
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
          enable_in_insert = true,
        },
        symbol_in_winbar = {
          enable = true,
          color_mode = true,
        },
      })
    end,
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
      "WhoIsSethDaniel/lualine-lsp-progress.nvim",
    },
    keys = {
      { "<leader>mD", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover docs" },
      { "<leader>mI", "<cmd>Lspsaga incoming_calls<CR>", desc = "Incoming calls" },
      { "<leader>mO", "<cmd>Lspsaga outgoing_calls<CR>", desc = "Outgoing calls" },
      { "<leader>ma", "<cmd>Lspsaga code_action<CR>", desc = "Code action" },
      { "<leader>md", "<cmd>Telescope lsp_definitions<cr>", desc = "Definition" },
      { "<leader>me", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      { "<leader>mf", "<cmd>Lspsaga finder<CR>", desc = "Find" },
      { "<leader>mh", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "Hover" },
      { "<leader>mi", "<cmd>Telescope lsp_implementations<cr>", desc = "Implementation" },
      { "<leader>ml", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "Codelens run" },
      { "<leader>mn", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Diagnostic Next" },
      { "<leader>mo", "<cmd>Outline<CR>", desc = "Outline" },
      { "<leader>mp", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek" },
      { "<leader>mr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
      { "<leader>ms", "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "Signature" },
      { "<leader>x<space>", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
    },
  },
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      log_level = vim.log.levels.ERROR,
      ensure_installed = {
        "stylua",
      },
    },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
    end,
  },
  {
    "tamago324/nlsp-settings.nvim",
    cmd = "LspSettings",
    opts = {},
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      local lsp_lines = require("lsp_lines")
      lsp_lines.setup()
      vim.keymap.set("", "<leader>cL", lsp_lines.toggle, { desc = "Toggle lsp_lines" })
    end,
  },
  -- this is based on from https://www.lazyvim.org/extras/lang/scala
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        -- turn off lsp diagnostics because lsp_lines is doing a better job
        virtual_text = false,
      },
      servers = {
        metals = {
          keys = {
            {
              "<leader>me",
              function()
                require("telescope").extensions.metals.commands()
              end,
              desc = "Metals commands",
            },
            {
              "<leader>mc",
              function()
                require("metals").compile_cascade()
              end,
              desc = "Metals compile cascade",
            },
            { "<leader>mmC", "<cmd>Telescope metals commands<cr>", desc = "Metals commands" },
            { "<leader>mmF", "<cmd>MetalsFindInDependencyJars<cr>", desc = "Find in dependency jars" },
            { "<leader>mmR", "<cmd>MetalsRestartBuild<cr>", desc = "Restart Build" },
            { "<leader>mmR", "<cmd>lua require'dap'.run_last()<cr>", desc = "Run last" },
            { "<leader>mmS", "<cmd>MetalsSwitchBsp<cr>", desc = "Switch build server" },
            { "<leader>mmT", "<cmd>lua require('metals.tvp').toggle_tree_view()<CR>", desc = "Toggle Tree View" },
            { "<leader>mmc", "<cmd>MetalsCompileClean<cr>", desc = "Clean compile" },
            { "<leader>mmd", "<cmd>MetalsRunDoctor<cr>", desc = "Doctor" },
            { "<leader>mmh", "<cmd>MetalsSuperMethodHierarchy<cr>", desc = "Supermethod Heirarchy" },
            { "<leader>mmi", "<cmd>MetalsImportBuild<cr>", desc = "Import Build" },
            { "<leader>mml", "<cmd>MetalsToggleLogs<cr>", desc = "Toggle Logs" },
            { "<leader>mmr", "<cmd>lua require('metals.tvp').reveal_in_tree()<CR>", desc = "Reveal in Tree View" },
            { "<leader>mms", "<cmd>MetalsSelectTestSuite<cr>", desc = "Select Test Suite" },
            { "<leader>mmt", "<esc>:DapContinue<cr>", desc = "Run test" },
            { "<leader>mmu", "<cmd>MetalsUpdate<cr>", desc = "Update" },
            { "<leader>mmI", "<cmd>lua print(vim.inspect(vim.lsp.get_active_clients()))<cr>", desc = "LSP Inspect" },
            { "gh", "<cmd>MetalsSuperMethodHierarchy<cr>", desc = "Supermethod Heirarchy" },
          },
          init_options = {
            statusBarProvider = "off",
          },
          settings = {
            showImplicitArguments = true,
            showInferredType = true,
            superMethodLensesEnabled = true,
            excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
          },
        },
      },
    },
  },
}
