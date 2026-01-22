return {
  "stevearc/overseer.nvim",
  config = function()
    local overseer = require("overseer")
    
    -- Register custom templates
    overseer.register_template({
      name = "sbt test",
      params = {},
      condition = {
        dir = vim.fn.getcwd(),
      },
      builder = function()
        return {
          cmd = { "sbt" },
          args = { "test" },
        }
      end,
    })

    overseer.register_template({
      name = "sbt integration tests",
      params = {},
      condition = {
        dir = vim.fn.expand("~/dev/sxm"),
      },
      builder = function()
        return {
          cmd = { "sbt" },
          args = { "it" },
        }
      end,
    })

    overseer.register_template({
      name = "sbt format",
      params = {},
      condition = {
        dir = vim.fn.getcwd(),
      },
      builder = function()
        return {
          cmd = { "sbt" },
          args = { "scalafmtFormatAll" },
        }
      end,
    })

    overseer.register_template({
      name = "sbt updates",
      params = {},
      condition = {
        dir = vim.fn.getcwd(),
      },
      builder = function()
        return {
          cmd = { "sbt" },
          args = { "dependencyUpdates; reload plugins; dependencyUpdates" },
        }
      end,
    })
  end,
}
