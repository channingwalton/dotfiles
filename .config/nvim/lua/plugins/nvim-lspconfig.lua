-- https://www.lazyvim.org/plugins/lsp#nvim-lspconfig

vim.lsp.set_log_level(vim.log.levels.ERROR)
vim.g.autoformat = true

vim.keymap.set("v", "<leader>ma", vim.lsp.buf.code_action)

return {
  -- this is based on https://www.lazyvim.org/extras/lang/scala
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        metals = {
          keys = {
            {
              "<leader>mm",
              function()
                local fzf = require("fzf-lua")
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

                fzf.fzf_exec(commands, {
                  actions = {
                    ["default"] = function(selected)
                      vim.cmd(selected[1])
                    end,
                  },
                })
              end,
              desc = "Metals commands",
            },
            { "<leader>mT", "<cmd>lua require('metals.tvp').toggle_tree_view()<CR>", desc = "Toggle Tree View" },
            { "<leader>mR", "<cmd>lua require('metals.tvp').reveal_in_tree()<CR>", desc = "Reveal in Tree View" },
            { "gh", "<cmd>MetalsSuperMethodHierarchy<cr>", desc = "Supermethod Heirarchy" },
          },
          init_options = {
            statusBarProvider = "off",
          },
          settings = {
            defaultBspToBuildTool = true,
            useGlobalExecutable = true, -- use the globally installed metals: cs install metals
            showImplicitArguments = true,
            showInferredType = true,
            superMethodLensesEnabled = true,
            startMcpServer = true,
            mcpClient = "claude",
            excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
            inlayHints = {
              byNameParameters = { enable = true },
              hintsInPatternMatch = { enable = true },
              implicitArguments = { enable = true },
              implicitConversions = { enable = true },
              inferredTypes = { enable = true },
              typeParameters = { enable = true },
              hintsXRayMode = { enable = true },
            },
            -- copied from VSCode settings
            serverProperties = {
              "-Xss4m",
              "-XX:+UseStringDeduplication",
              "-XX:+IgnoreUnrecognizedVMOptions",
              "-XX:ZCollectionInterval=5",
              "-XX:ZUncommitDelay=30",
              "-XX:+UseZGC",
              "-Xmx2G",
            },
            --serverVersion = "1.4.2+80-2b937bb1-SNAPSHOT",
          },
        },
      },
    },
    keys = {
      { "<leader>md", "<cmd>FzfLua lsp_definitions<cr>", desc = "Definition" },
      { "<leader>mR", "<cmd>FzfLua lsp_references<cr>", desc = "References" },
      { "<leader>mi", "<cmd>FzfLua lsp_implementations<cr>", desc = "Implementation" },
      { "<leader>ml", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "Codelens run" },
      { "<leader>mo", "<cmd>Outline<CR>", desc = "Outline" },
      { "<leader>ms", "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "Signature" },
      { "<leader>x<space>", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },
    },
  },
  {
    "nvimdev/lspsaga.nvim",
    lazy = false,
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
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
      -- LSP Actions
      { "<leader>ma", "<cmd>Lspsaga code_action<CR>", desc = "Code action" },
      { "<leader>mh", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover docs" },
      { "<leader>mf", "<cmd>Lspsaga finder<CR>", desc = "Find" },
      { "<leader>mp", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek" },
      { "<leader>mr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
      { "<leader>mI", "<cmd>Lspsaga incoming_calls<CR>", desc = "Incoming calls" },
      { "<leader>mO", "<cmd>Lspsaga outgoing_calls<CR>", desc = "Outgoing calls" },
      { "<leader>mn", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Diagnostic Next" },

      -- Metals Build
      { "<leader>mb", "<cmd>lua require('metals').connect_build()<cr>", desc = "Connect Build" },
      { "<leader>mB", "<cmd>lua require('metals').disconnect_build()<cr>", desc = "Disconnect Build" },
      { "<leader>mi", "<cmd>lua require('metals').import_build()<cr>", desc = "Import Build" },
      { "<leader>mx", "<cmd>lua require('metals').restart_build_server()<cr>", desc = "Restart Build Server" },

      -- Metals Compile
      { "<leader>mc", "<cmd>lua require('metals').compile_cascade()<cr>", desc = "Compile Cascade" },
      { "<leader>mC", "<cmd>lua require('metals').compile_clean()<cr>", desc = "Compile Clean" },

      -- Metals Workspace
      { "<leader>mR", "<cmd>lua require('metals').reset_workspace()<cr>", desc = "Reset Workspace" },
      { "<leader>mz", "<cmd>lua require('metals').restart_metals()<cr>", desc = "Restart Metals" },
      { "<leader>mD", "<cmd>lua require('metals').run_doctor()<cr>", desc = "Run Doctor" },
      { "<leader>ml", "<cmd>lua require('metals').toggle_logs()<cr>", desc = "Toggle Logs" },

      -- Metals Code
      { "<leader>mF", "<cmd>lua require('metals').run_scalafix()<cr>", desc = "Run Scalafix" },
      { "<leader>mo", "<cmd>lua require('metals').organize_imports()<cr>", desc = "Organize Imports" },
      { "<leader>mS", "<cmd>lua require('metals').goto_super_method()<cr>", desc = "Goto Super Method" },
      { "<leader>ms", "<cmd>lua require('metals').super_method_hierarchy()<cr>", desc = "Super Method Hierarchy" },
      { "<leader>mN", "<cmd>lua require('metals').new_scala_file()<cr>", desc = "New Scala File" },
      { "<leader>mw", "<cmd>lua require('metals').quick_worksheet()<cr>", desc = "Quick Worksheet" },

      -- Tree View
      { "<leader>tr", "<cmd>lua require('metals.tvp').reveal_in_tree()<cr>", desc = "Reveal in Tree" },
      { "<leader>tv", "<cmd>lua require('metals.tvp').toggle_tree_view()<cr>", desc = "Toggle Tree View" },

      -- Special Keys
      { "K", "<cmd>lua require('metals').hover_worksheet()<cr>", desc = "Hover Worksheet", ft = "scala" },
      { "<F9>", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "Toggle Breakpoint" },
      { "<F5>", "<cmd>lua require('dap').continue()<cr>", desc = "Continue" },
      { "<F10>", "<cmd>lua require('dap').step_over()<cr>", desc = "Step Over" },
      { "<F11>", "<cmd>lua require('dap').step_into()<cr>", desc = "Step Into" },
      { "<S-F11>", "<cmd>lua require('dap').step_out()<cr>", desc = "Step Out" },
      { "<C-F8>", "<cmd>lua require('dap').run_to_cursor()<cr>", desc = "Run to Cursor" },
    },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      local lsp_lines = require("lsp_lines")
      lsp_lines.setup()
      vim.keymap.set("", "<leader>cL", lsp_lines.toggle, { desc = "Toggle lsp_lines" })
      -- Disable virtual_text since it's redundant due to lsp_lines.
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
