return {
  "stevearc/overseer.nvim",
  require("overseer").register_template({
    name = "sbt test",
    params = {},
    condition = {
      -- This makes the template only available in the current directory
      -- In case you :cd out later
      dir = vim.fn.getcwd(),
      filetype = { "scala" },
    },
    builder = function()
      return {
        cmd = { "sbt" },
        args = { "test" },
      }
    end,
  }),
  require("overseer").register_template({
    name = "sbt integration tests",
    params = {},
    condition = {
      -- This makes the template only available in the current directory
      -- In case you :cd out later
      dir = "~/dev/sxm",
    },
    builder = function()
      return {
        cmd = { "sbt" },
        args = { "it" },
      }
    end,
  }),
  require("overseer").register_template({
    name = "sbt format",
    params = {},
    condition = {
      -- This makes the template only available in the current directory
      -- In case you :cd out later
      dir = vim.fn.getcwd(),
    },
    builder = function()
      return {
        cmd = { "sbt" },
        args = { "scalafmtFormatAll" },
      }
    end,
  }),
}
