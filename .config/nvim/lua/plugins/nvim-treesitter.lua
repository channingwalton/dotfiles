return {
  -- Extend LazyVim's default nvim-treesitter configuration
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Extend the default ensure_installed list
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "c",
        "css", 
        "dockerfile",
        "gitignore",
        "graphql",
        "html",
        "http",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "prisma",
        "python",
        "query",
        "regex",
        "scala",
        "svelte",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })

      -- Override/extend other options
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true
      
      opts.indent = opts.indent or {}
      opts.indent.enable = true
      
      opts.incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<M-up>",
          node_incremental = "<M-up>",
          scope_incremental = false,
          node_decremental = "<M-down>",
        },
      }
    end,
  },
}
