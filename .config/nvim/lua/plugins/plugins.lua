return {
  -- LSP (Language Server Protocol) setup
  { "neovim/nvim-lspconfig" },

  -- Additional LSP support plugins
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Autocompletion plugins
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },

  --Plugin to enhance diagnostic display
  {
    {
      "folke/trouble.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("trouble").setup()
      end,
    },
  },

  --Autoformatting with null-ls
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier, -- For JavaScript/TypeScript/CSS/HTML
          null_ls.builtins.formatting.gofmt, -- For Go
          null_ls.builtins.formatting.black, -- For Python
        },
      })
    end,
  },

  -- Snippet support
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- Syntax highlighting for treesitter
  { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
}
