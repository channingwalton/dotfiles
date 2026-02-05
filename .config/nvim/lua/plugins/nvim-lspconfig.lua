-- https://www.lazyvim.org/plugins/lsp#nvim-lspconfig

vim.lsp.set_log_level(vim.log.levels.ERROR)
vim.g.autoformat = true

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

      -- Metals command picker
      {
        "<leader>mm",
        function()
          local commands = {
            "MetalsCompileCancel",
            "MetalsCompileCascade",
            "MetalsCompileClean",
            "MetalsImportBuild",
            "MetalsInfo",
            "MetalsToggleLogs",
            "MetalsRestartBuildServer",
            "MetalsRestartMetals",
            "MetalsRunDoctor",
            "MetalsRunWorksheet",
            "MetalsSwitchBsp",
            "MetalsUpdate",
          }

          Snacks.picker.pick({
            title = "Metals",
            items = vim.tbl_map(function(cmd)
              return { text = cmd, cmd = cmd }
            end, commands),
            confirm = function(picker, item)
              picker:close()
              if item then
                vim.cmd(item.cmd)
              end
            end,
          })
        end,
        desc = "Metals commands",
      },
      { "<leader>mT", "<cmd>lua require('metals.tvp').toggle_tree_view()<CR>", desc = "Toggle Tree View" },
      { "<leader>mV", "<cmd>lua require('metals.tvp').reveal_in_tree()<CR>", desc = "Reveal in Tree View" },
      { "gh", "<cmd>MetalsSuperMethodHierarchy<cr>", desc = "Supermethod Hierarchy" },
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
        enable_in_insert = true,
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

      -- Metals Build Commands
      { "<leader>mb", "<cmd>lua require('metals').connect_build()<cr>", desc = "Connect Build" },
      { "<leader>mB", "<cmd>lua require('metals').disconnect_build()<cr>", desc = "Disconnect Build" },
      { "<leader>mx", "<cmd>lua require('metals').restart_build_server()<cr>", desc = "Restart Build Server" },

      -- Metals Compile Commands
      { "<leader>mc", "<cmd>lua require('metals').compile_cascade()<cr>", desc = "Compile Cascade" },
      { "<leader>mC", "<cmd>lua require('metals').compile_clean()<cr>", desc = "Compile Clean" },

      -- Metals Workspace Commands
      { "<leader>mw", "<cmd>lua require('metals').reset_workspace()<cr>", desc = "Reset Workspace" },
      { "<leader>mz", "<cmd>lua require('metals').restart_metals()<cr>", desc = "Restart Metals" },
      { "<leader>mD", "<cmd>lua require('metals').run_doctor()<cr>", desc = "Run Doctor" },
      { "<leader>mL", "<cmd>lua require('metals').toggle_logs()<cr>", desc = "Toggle Logs" },

      -- Metals Code Commands
      { "<leader>mF", "<cmd>lua require('metals').run_scalafix()<cr>", desc = "Run Scalafix" },
      { "<leader>mG", "<cmd>lua require('metals').organize_imports()<cr>", desc = "Organize Imports" },
      { "<leader>mS", "<cmd>lua require('metals').goto_super_method()<cr>", desc = "Goto Super Method" },
      { "<leader>mH", "<cmd>lua require('metals').super_method_hierarchy()<cr>", desc = "Super Method Hierarchy" },
      { "<leader>mN", "<cmd>lua require('metals').new_scala_file()<cr>", desc = "New Scala File" },
      { "<leader>mW", "<cmd>lua require('metals').quick_worksheet()<cr>", desc = "Quick Worksheet" },

      -- Tree View Commands
      { "<leader>tr", "<cmd>lua require('metals.tvp').reveal_in_tree()<cr>", desc = "Reveal in Tree" },
      { "<leader>tv", "<cmd>lua require('metals.tvp').toggle_tree_view()<cr>", desc = "Toggle Tree View" },

      -- Special Function Keys for Debugging
      { "<F9>", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "Toggle Breakpoint" },
      { "<F5>", "<cmd>lua require('dap').continue()<cr>", desc = "Continue" },
      { "<F10>", "<cmd>lua require('dap').step_over()<cr>", desc = "Step Over" },
      { "<F11>", "<cmd>lua require('dap').step_into()<cr>", desc = "Step Into" },
      { "<S-F11>", "<cmd>lua require('dap').step_out()<cr>", desc = "Step Out" },
      { "<C-F8>", "<cmd>lua require('dap').run_to_cursor()<cr>", desc = "Run to Cursor" },

      -- Scala-specific overrides
      { "K", "<cmd>lua require('metals').hover_worksheet()<cr>", desc = "Hover Worksheet", ft = "scala" },
    },
  },

  -- Enhanced LSP diagnostics display
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    opts = {},
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
