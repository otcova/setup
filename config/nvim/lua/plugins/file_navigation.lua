-- Alternate file (:e#)
vim.keymap.set("n", "<leader>a", "<cmd>e#<cr>")


return {
  -- File explorer
  {
    "echasnovski/mini.files",
    event = "BufEnter",
    config = function()
      require("mini.files").setup({
        mappings = {
          synchronize = "<leader>w",
          go_in       = 'L',
          go_in_plus  = 'l',
        }
      })

      vim.api.nvim_create_user_command("Ex", function(opts)
        MiniFiles.open(opts.args)
      end, {
        nargs = "?",
        complete = "file",
        desc = "Open MiniFiles in current or specified directory",
      })

      local original_open = MiniFiles.open
      MiniFiles.open = function(path, use_latest, opts)
        -- If path does not exists get the parent
        local prev_path = ""
        while path ~= prev_path and vim.loop.fs_stat(path) == nil do
          prev_path = path
          path = vim.fn.fnamemodify(path, ":h")
        end

        original_open(path, use_latest, opts)
        MiniFiles.reveal_cwd()
      end
    end,
    keys = {
      {
        "<leader>e",
        function()
          MiniFiles.open(vim.api.nvim_buf_get_name(0))
        end,
        desc = "Explorer",
      }
    },
  },
  -- Explicit Tabs
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    lazy = true,
    config = function()
      local harpoon = require("harpoon")
      local extensions = require("harpoon.extensions")

      -- -- Add icons to items
      -- harpoon:setup({
      --   default = {
      --     display = function(item)
      --       local t = MiniIcons.get("file", item.value)
      --       return t .. " " .. item.value
      --     end,
      --   }
      -- })
      harpoon:extend(extensions.builtins.highlight_current_file())
    end,
    keys = {
      -- Register current buffer
      { "<leader>r", function() require("harpoon"):list():add() end },

      -- Open tabs menu
      { "<leader>t", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end },

      -- Goto tab
      { "<leader>1", function() require("harpoon"):list():select(1) end },
      { "<leader>2", function() require("harpoon"):list():select(2) end },
      { "<leader>3", function() require("harpoon"):list():select(3) end },
      { "<leader>4", function() require("harpoon"):list():select(4) end },
      { "<leader>5", function() require("harpoon"):list():select(5) end },
      { "<leader>6", function() require("harpoon"):list():select(6) end },
      { "<leader>7", function() require("harpoon"):list():select(7) end },
      { "<leader>8", function() require("harpoon"):list():select(8) end },
      { "<leader>9", function() require("harpoon"):list():select(9) end },
      { "<leader>0", function() require("harpoon"):list():select(10) end },
    },
    opts = {},
  },
  -- Pickers
  {
    'nvim-telescope/telescope.nvim',
    lazy = true,
    cmd = "Telescope",
    keys = {
      -- Generic picker
      { "<leader>f",   function() require('telescope.builtin').find_files() end },
      { "<leader>/",   function() require('telescope.builtin').live_grep() end },
      { "<leader>pg",  function() require('telescope.builtin').live_grep() end },
      { "<leader>pr",  function() require('telescope.builtin').resume() end },
      { "<leader>pb",  function() require('telescope.builtin').buffers() end },
      { "<leader>ph",  function() require('telescope.builtin').help_tags() end },
      { "<leader>pc",  function() require('telescope.builtin').commands() end },
      { "<leader>po",  function() require('telescope.builtin').oldfiles() end },
      { "<leader>py",  function() require('telescope.builtin').command_history() end },
      { "<leader>ps",  function() require('telescope.builtin').search_history() end },
      { "<leader>pk",  function() require('telescope.builtin').keymaps() end },
      { "<leader>pn",  function() require('telescope').extensions.notify.notify() end },

      -- Lsp picker
      { "<leader>d",   function() require('telescope.builtin').diagnostics() end },
      { "<leader>lr",  function() require('telescope.builtin').lsp_references() end },
      { "<leader>ld",  function() require('telescope.builtin').lsp_definitions() end },
      { "<leader>lt",  function() require('telescope.builtin').lsp_type_definitions() end },
      { "<leader>li",  function() require('telescope.builtin').lsp_implementations() end },
      { "<leader>lci", function() require('telescope.builtin').lsp_incoming_calls() end },
      { "<leader>lco", function() require('telescope.builtin').lsp_outgoing_calls() end },

      -- Git picker
      { "<leader>gc",  function() require('telescope.builtin').git_commits() end },
      { "<leader>gb",  function() require('telescope.builtin').git_branches() end },
      { "<leader>gs",  function() require('telescope.builtin').git_status() end },
      { "<leader>gh",  function() require('telescope.builtin').git_stash() end },
      { "<leader>gf",  function() require('telescope.builtin').git_bcommits() end },
    },
    opts = {},
  },
  -- Dependency
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },
}
