return {
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate", -- Automatically update parsers
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "go", "typescript", "python", "css", "html", "tailwindcss" },
        highlight = { enable = true },
        incremental_selection = { enable = true },
        textobjects = { enable = true },
      })
    end,
  },
}
