return {
  -- Colorscheme imported in "init_lazy.lua"

  -- Nice UI prompts
  -- ':mes' to show messages/errors in a buffer
  {
    "folke/noice.nvim",
    lazy = false,
    opts = {
      presets = {
        bottom_search = true,
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      -- Prevent common and non relevant LOG messages from using popup
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
              { find = "%d+ lines yanked" },
              { find = "%d+ fewer lines" },
              { find = "-- Lines in buffer --" },
            },
          },
          view = "mini",
        },
      },
    },
    dependencies = {
      "rcarriga/nvim-notify",
    }
  },
  -- Nice UI for notifications
  -- "<CR>ww" to focus notification (to prevent close) or to copy thing from there
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      render = "minimal",
      max_width = 60,
      stages = "fade",
      timeout = 7000,
      merge_duplicates = false,
    },
  },
  -- File icons
  {
    "echasnovski/mini.icons",
    event = "BufEnter",
    opts = {},
  },
  -- Center Single Buffers
  {
    "shortcuts/no-neck-pain.nvim",
    event = "BufEnter",
    opts = {
      width = 120,
      autocmds = {
        enableOnVimEnter = true,
        skipEnteringNoNeckPainBuffer = true,
      },
      buffers = {
        scratchPad = {
          fileName = "notes",
          location = "~/Documents/",
        },
        bo = {
          filetype = "md",
        }
      }
    },
    keys = {
      {
        "<leader>n",
        function()
          local no_neck_pain = require("no-neck-pain")
          no_neck_pain.enable()
          vim.defer_fn(no_neck_pain.toggle_scratchPad, 50)
        end,
        { desc = "Open notes" }
      }
    },
  },
  {
    "folke/todo-comments.nvim",
    opts = {},
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    --dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    --dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' }, -- if you use standalone mini plugins
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      render_modes = { 'n', 'c', 't', 'i' },
      code = {
        border = "thin",
      },
    },
  }
}
