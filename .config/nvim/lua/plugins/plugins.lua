return {
  -- LSP (Language Server Protocol) setup
  { "neovim/nvim-lspconfig" },

  -- Additional LSP support plugins
  { "mason-org/mason.nvim" },
  { "mason-org/mason-lspconfig.nvim" },

  -- Autocompletion plugins
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip", -- Ensure LuaSnip is loaded
    },
  },

  -- Plugin to enhance diagnostic display
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup()
    end,
  },

  -- Snippet support
  { "L3MON4D3/LuaSnip" },

  -- Syntax highlighting for treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
}
