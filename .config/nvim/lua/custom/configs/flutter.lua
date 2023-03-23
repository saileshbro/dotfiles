require("flutter-tools").setup {
  ui = {
    border = "rounded" 
  },
  decorations = {
    statusline = {
      app_version = true,
      device = true
    }
  },
  debugger = {
    enabled = true,
    run_via_dap = true,
    exception_breakpoints = {},
    register_configurations = function(_)
      local dap = require('dap')
      dap.adapters.dart = {
        type = "executable",
        command = 'node',
        args = { debugger_path, "flutter"}
      },
      require('dap.ext.vscode').load_launchjs(require('flutter-tools.lsp').get_lsp_root_dir() .. '/.vscode/launch.json')
    end,
  },
  outline = { auto_open = false },
  widget_guides = { enabled = true, debug = false},
  fvm = true,
  lsp = {
    color = {
      enabled = true,
      background = true,
      virtual_text = false,
    },
    settings = {
      showTodos = false,
      renameFilesWithClasses = 'prompt',
      updateImportsOnRename = true,
      completeFunctionCalls = true,
      lineLength = 100,
    },
  },
};

