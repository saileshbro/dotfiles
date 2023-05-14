
local present, wk = pcall(require, "copilot")

if not present then
  return
end

local options = {
}

options = require("core.utils").load_override(options, "gihub/copilot.nvim")

wk.setup(options)
