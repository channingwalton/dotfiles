return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          ".DS_Store",
          ".git",
        },
      },
      follow_current_file = {
        enabled = true,
        leave_dirs_open = true,
        group_empty_dirs = true,
      },
    },
  },
}
