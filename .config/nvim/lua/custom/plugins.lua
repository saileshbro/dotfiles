local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {


  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = overrides.mason
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "folke/which-key.nvim",
    enabled = true,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },

  {
    "ggandor/lightspeed.nvim",
    after = "alpha",
    disable = false,
    config = function()
      require "custom.configs.lightspeed"
    end,
  },

  -- overrde plugin configs
  {
    "nvim-treesitter/nvim-treesitter",
    override_options = overrides.treesitter,
  },

  {
    "williamboman/mason.nvim",
    override_options = overrides.mason,
  },

  {
    "nvim-tree/nvim-tree.lua",
    override_options = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    --   event = "InsertEnter",
    --   config = function()
    --     require("better_escape").setup()
    --   end,
    -- },

    -- code formatting, linting etc
    {
      "jose-elias-alvarez/null-ls.nvim",
      after = "nvim-lspconfig",
      config = function()
        require "custom.configs.null-ls"
      end,
    },


    -- remove plugin
    -- markdown previewer
    {
      "toppair/peek.nvim",
      run = "deno taks --quiet build:fast",
      disable = false,
      config = function()
        require "custom.configs.peek"
      end,
    },

    {
      "akinsho/flutter-tools.nvim",
      lazy = false,
      dependencies = {
        'nvim-lua/plenary.nvim',
        'stevearc/dressing.nvim',
      },
      config = function()
        require "custom.configs.flutter"
      end,
    },
    {
      "github/copilot.vim",
      lazy = false,
      config = function()
        require "custom.configs.copilot"
      end,
    },
    {
      "b0o/schemastore.nvim",
      lazy = false,
      config = function()
        require('lspconfig').jsonls.setup{
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        }
      end,
    },
    {
      "mfussenegger/nvim-dap",
      config = function()
        require "custom.configs.nvim-dap"
      end,
    },
    {
      "alexghergh/nvim-tmux-navigation",
      lazy = false,
      config = function()
        require'nvim-tmux-navigation'.setup {
            disable_when_zoomed = true, -- defaults to false
            keybindings = {
                left = "<C-h>",
                down = "<C-j>",
                up = "<C-k>",
                right = "<C-l>",
                last_active = "<C-\\>",
                next = "<C-Space>",
            }
        }
      end,
    }
  },
}

return plugins
