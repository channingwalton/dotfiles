-- Override LazyVim's scala extra with custom metals settings
return {
  {
    "scalameta/nvim-metals",
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

      metals_config.on_attach = function(client, bufnr)
        require("metals").setup_dap()
      end

      return metals_config
    end,
  },
}
