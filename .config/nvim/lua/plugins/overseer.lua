return {
  "stevearc/overseer.nvim",
  opts = function(_, opts)
    return vim.tbl_deep_extend("force", opts, {
      templates = { "builtin" },
    })
  end,
  config = function(_, opts)
    local overseer = require("overseer")
    overseer.setup(opts)

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
