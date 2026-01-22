return {
  "nvim-neotest/neotest",
  dependencies = {
    "stevanmilic/neotest-scala",
  },
  opts = {
    -- Can be a list of adapters like what neotest expects,
    -- or a list of adapter names,
    -- or a table of adapter names, mapped to adapter configs.
    -- The adapter will then be automatically loaded with the config.
    adapters = {
      ["neotest-scala"] = {
        -- Command line arguments for runner
        -- Can also be a function to return dynamic values
        args = { "--no-color" },
        -- Runner to use. Will use bloop by default.
        -- Can be a function to return dynamic value.
        -- For backwards compatibility, it also tries to read the vim-test scala config.
        -- Possibly values bloop|sbt.
        runner = "bloop",
        -- Test framework to use. Will use utest by default.
        -- Can be a function to return dynamic value.
        -- Possibly values utest|munit|scalatest.
        framework = "munit",
      },
    },
    -- Example for loading neotest-go with a custom config
    -- adapters = {
    --   ["neotest-go"] = {
    --     args = { "-tags=integration" },
    --   },
    -- },
    status = { virtual_text = true },
    output = { open_on_run = true },
    quickfix = {
      open = function()
        if LazyVim.has("trouble.nvim") then
          require("trouble").open({ mode = "quickfix", focus = false })
        else
          vim.cmd("copen")
        end
      end,
    },
  },
}
