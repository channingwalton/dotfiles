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
}
