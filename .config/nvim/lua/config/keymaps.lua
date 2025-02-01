-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { silent = true, noremap = true })

-- Save and format with <leader>s+a
vim.api.nvim_set_keymap(
  "n",
  "<leader>mb",
  "<cmd>lua vim.lsp.buf.format({ async = true }); vim.cmd('write')<CR>",
  { noremap = true, silent = true }
)

-- Toggle Trouble with <leader>xx
vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { noremap = true, silent = true })
