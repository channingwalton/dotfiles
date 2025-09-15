return {
  "ibhagwan/fzf-lua",
  opts = {
    grep = {
      rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
      hidden = true,
    },
  },
  keys = {
    {
      "<leader>fl",
      "<cmd>FzfLua files<cr>",
      desc = "List files in current folder",
    },
    {
      "<leader>gx",
      function()
        require("fzf-lua").fzf_exec("git diff --name-only --diff-filter=U --relative", {
          prompt = "Conflicts❯ ",
          actions = {
            ["default"] = require("fzf-lua").actions.file_edit,
          },
        })
      end,
      desc = "Conflicts",
    },
  },
}

