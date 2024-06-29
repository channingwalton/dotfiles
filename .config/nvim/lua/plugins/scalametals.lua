-- Based on https://github.com/scalameta/nvim-metals/discussions/39
--
return {
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "j-hui/fidget.nvim",
        opts = {},
      },
    },
    init = function()
      local metals_config = require("metals").bare_config()

      metals_config.settings = {
        showImplicitArguments = true,
        showInferredType = true,
        superMethodLensesEnabled = true,
        excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
        serverVersion = "latest.snapshot",
      }

      -- *READ THIS*
      -- I *highly* recommend setting statusBarProvider to either "off" or "on"
      --
      -- "off" will enable LSP progress notifications by Metals and you'll need
      -- to ensure you have a plugin like fidget.nvim installed to handle them.
      --
      -- "on" will enable the custom Metals status extension and you *have* to have
      -- a have settings to capture this in your statusline or else you'll not see
      -- any messages from metals. There is more info in the help docs about this
      metals_config.init_options.statusBarProvider = "off"

      -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
      metals_config.capabilities.textDocument.completion.completionItem.snippetSupport = true
      metals_config.capabilities.textDocument.completion.dynamicRegistration = true

      metals_config.on_attach = function(_, _)
        require("metals").setup_dap()
      end

      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt", "java" },
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,

    require("which-key").register({
      ["<leader>m"] = {
        name = "+metals",
      },
    }),

    keys = {
      { "<leader>mm", desc = "Metals" },
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
  },
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
