local present, wk = pcall(require, "nvim-dap")

if not present then
  return
end

local options = {

}

options = require("core.utils").load_override(options, "mfussenegger/nvim-dap.nvim")

wk.setup(options)
