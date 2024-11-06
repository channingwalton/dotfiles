return {
  "axkirillov/easypick.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    local easypick = require("easypick")
    easypick.setup({
      pickers = {
        {
          name = "ls",
          command = "ls",
          previewer = easypick.previewers.default(),
        },
        {
          name = "diff_with_origin",
          command = "branch=$(git rev-parse --abbrev-ref HEAD) git diff --name-only $branch `origin/$branch`",
          -- previewer = easypick.previewers.branch_diff({ base_branch = base_branch }),
          previewer = easypick.previewers.default(),
        },
        {
          name = "diff_with_main",
          command = "branch=$(git rev-parse --abbrev-ref HEAD) git diff --name-only $branch main",
          previewer = easypick.previewers.default(),
        },
        {
          name = "conflicts",
          command = "git diff --name-only --diff-filter=U --relative",
          previewer = easypick.previewers.file_diff(),
        },
      },
    })
  end,

  keys = {
    {
      "<leader>fl",
      ":Easypick ls<cr>",
      desc = "List files in current folder",
    },
    {
      "<leader>gx",
      ":Easypick conflicts<cr>",
      desc = "Conflicts",
    },
  },
}
