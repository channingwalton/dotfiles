-- Override LazyVim's scala extra with custom metals settings
return {
  {
    "scalameta/nvim-metals",
    keys = function(_, keys)
      local inherited = {
        ["<leader>me"] = true,
        ["<leader>mc"] = true,
        ["<leader>mh"] = true,
      }

      return vim.tbl_filter(function(key)
        return not inherited[type(key) == "string" and key or key[1]]
      end, keys)
    end,
    opts = function()
      local metals_config = require("metals").bare_config()

      metals_config.init_options.statusBarProvider = "off"

      metals_config.settings = {
        defaultBspToBuildTool = false,
        mcpClient = "claude",
        showImplicitArguments = true,
        showInferredType = true,
        startMcpServer = true,
        superMethodLensesEnabled = true,
        useGlobalExecutable = true, -- use the globally installed metals: cs install metals
        verboseCompilation = true,
        showImplicitConversionsAndClasses = true,
        testUserInterface = "Test Explorer",
        excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
        inlayHints = {
          byNameParameters = { enable = true },
          hintsInPatternMatch = { enable = true },
          hintsXRayMode = { enable = true },
          implicitArguments = { enable = true },
          implicitConversions = { enable = true },
          inferredTypes = { enable = true },
          typeParameters = { enable = true },
        },
        -- copied from VSCode settings
        serverProperties = {
          "-Xss4m",
          "-XX:+UseStringDeduplication",
          "-XX:+IgnoreUnrecognizedVMOptions",
          "-XX:ZCollectionInterval=5",
          "-XX:ZUncommitDelay=30",
          "-XX:+UseZGC",
          "-Xmx2G",
        },
      }

      metals_config.on_attach = function(_client, bufnr)
        require("metals").setup_dap()

        local metals = require("metals")
        local tvp = require("metals.tvp")

        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("<leader>mm", function()
          local commands = {
            "MetalsCompileCancel",
            "MetalsCompileCascade",
            "MetalsCompileClean",
            "MetalsImportBuild",
            "MetalsInfo",
            "MetalsToggleLogs",
            "MetalsRestartBuildServer",
            "MetalsRestartMetals",
            "MetalsRunDoctor",
            "MetalsRunWorksheet",
            "MetalsSwitchBsp",
            "MetalsUpdate",
          }

          Snacks.picker.pick({
            source = "metals",
            title = "Metals",
            items = vim.tbl_map(function(cmd)
              return { text = cmd, cmd = cmd }
            end, commands),
            format = "text",
            preview = "none",
            confirm = function(picker, item)
              picker:close()
              if item then
                vim.cmd(item.cmd)
              end
            end,
          })
        end, "Metals commands")

        map("<leader>mT", tvp.toggle_tree_view, "Toggle Tree View")
        map("<leader>mV", tvp.reveal_in_tree, "Reveal in Tree View")
        map("gh", metals.super_method_hierarchy, "Supermethod Hierarchy")

        map("<leader>mb", metals.connect_build, "Connect Build")
        map("<leader>mB", metals.disconnect_build, "Disconnect Build")
        map("<leader>mx", metals.restart_build_server, "Restart Build Server")

        map("<leader>mc", metals.compile_cascade, "Compile Cascade")
        map("<leader>mC", metals.compile_clean, "Compile Clean")

        map("<leader>mw", metals.reset_workspace, "Reset Workspace")
        map("<leader>mz", metals.restart_metals, "Restart Metals")
        map("<leader>mD", metals.run_doctor, "Run Doctor")
        map("<leader>mL", metals.toggle_logs, "Toggle Logs")

        map("<leader>mF", metals.run_scalafix, "Run Scalafix")
        map("<leader>mG", metals.organize_imports, "Organize Imports")
        map("<leader>mS", metals.goto_super_method, "Goto Super Method")
        map("<leader>mH", metals.super_method_hierarchy, "Super Method Hierarchy")
        map("<leader>mN", metals.new_scala_file, "New Scala File")
        map("<leader>mW", metals.quick_worksheet, "Quick Worksheet")
        map("<leader>mh", metals.hover_worksheet, "Hover Worksheet")
        map("K", metals.hover_worksheet, "Hover Worksheet")
      end

      return metals_config
    end,
  },
}
