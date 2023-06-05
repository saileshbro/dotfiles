local autocmd = vim.api.nvim_create_autocmd

local opt = vim.opt
local g = vim.g

-- for numbers
opt.relativenumber = true
vim.o.scrolloff = 8
vim.api.nvim_set_keymap('n', '<C-h>', ':NvimTmuxNavigateLeft<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', ':NvimTmuxNavigateDown<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':NvimTmuxNavigateUp<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', ':NvimTmuxNavigateRight<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-\\>', ':NvimTmuxNavigateLastActive<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-Space>', ':NvimTmuxNavigateNext<CR>', { silent = true })
-- vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})

vim.cmd "silent! command! PeekOpen lua require('peek').open()"
vim.cmd "silent! command! PeekClose lua require('peek').close()"
-- Auto resize panes when resizing nvim window
autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})
