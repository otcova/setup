-- Use powershell in windows
if vim.uv.os_uname().sysname:find("Windows") then
  vim.opt.shell = "powershell"
  vim.opt.shellcmdflag = "-command"
end

-- Detect indent
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()

    local indent2_score = 0
    local indent4_score = 0

    for i = 0, 200 do
      local line = vim.api.nvim_buf_get_lines(buf, i, i + 1, false)[1]
      if not line then
        break
      end

      local indent = #line:match("^%s*")
      if indent > 0 then
        if indent % 4 == 0 then
          indent4_score = indent4_score + 1
        else
          indent2_score = indent2_score + (indent % 2 == 0 and 2 or -1)
          indent4_score = indent4_score - 1
        end
      end
    end

    local threshold = 2
    if indent2_score - indent4_score >= threshold then
      vim.bo.shiftwidth = 2
      vim.bo.tabstop = 2
    elseif indent4_score - indent2_score >= threshold then
      vim.bo.shiftwidth = 4
      vim.bo.tabstop = 4
    end
  end,
})

-------------------------------------------
---------- Center Content -----------------
-------------------------------------------

local padding_win = nil
local padding_config = {
  -- Number of columns that the content should have centered after adding the padding.
  content_size = 100,
  -- Sizes will be multiple of 10, (This makes it easyer for things to align)
  round_scale = 10,
  blank_buffer = vim.api.nvim_create_buf(false, true),
}

vim.api.nvim_set_option_value("modifiable", false, { buf = padding_config.blank_buffer })

local function create_padding_win()
  if padding_win == nil then
    padding_win = vim.api.nvim_open_win(padding_config.blank_buffer, false, { split = "left" })

    local opts = { win = padding_win }
    vim.api.nvim_set_option_value("number", false, opts)
    vim.api.nvim_set_option_value("relativenumber", false, opts)
    vim.api.nvim_set_option_value("signcolumn", "no", opts)
    vim.api.nvim_set_option_value("cursorline", false, opts)
  end

  -- position
  vim.api.nvim_win_call(padding_win, function()
    vim.api.nvim_command("wincmd H")
  end)

  -- size
  local pad_width = vim.o.columns - padding_config.content_size
  local left_pad = pad_width / 2
  left_pad = math.floor(0.5 + left_pad / padding_config.round_scale) * padding_config.round_scale
  vim.api.nvim_win_set_width(padding_win, left_pad)
end

local function delete_padding_win()
  if padding_win ~= nil then
    vim.api.nvim_win_close(padding_win, false)
    padding_win = nil
  end
end

-- -- Redirect focus
-- vim.api.nvim_create_autocmd("WinEnter", {
--   callback = function()
--     if vim.api.nvim_get_current_win() == padding_win then
--       vim.api.nvim_command("wincmd l")
--       if vim.api.nvim_get_current_win() == padding_win then
--         padding_win = nil
--       end
--     end
--   end,
-- })

-- Add padding automatically
vim.api.nvim_create_autocmd({ "WinNew", "WinClosed", "VimResized", "WinResized", "BufReadPost", "BufNewFile" }, {
  callback = function(event)
    local event_win = tonumber(event.match)

    if event_win and (vim.api.nvim_win_get_config(event_win).relative or "") ~= "" then
      return
    end

    if padding_win and vim.api.nvim_win_get_buf(padding_win) ~= padding_config.blank_buffer then
      padding_win = nil
    end

    if event_win == padding_win and event.event == "WinClosed" then
      padding_win = nil
    end

    local content_window = nil

    for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if window ~= padding_win then
        if (vim.api.nvim_win_get_config(window).relative or "") == "" then
          if content_window then
            delete_padding_win()
            return
          end
          content_window = window
        end
      end
    end

    if content_window then
      create_padding_win()
      vim.api.nvim_set_current_win(content_window)
    end
  end,
})

-- create_padding_win()

-------------------------------------------
-------------------------------------------

return {
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = {
        disable = function(_, buf)
          local max_file_size = 1024 * 1024 -- 1 MB
          local max_file_width = 10 * 1024 -- 10KB

          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          local file_size = 0
          if ok and stats then
            file_size = stats.size
          end
          local mean_file_width = file_size / vim.api.nvim_buf_line_count(buf)
          return file_size > max_file_size or mean_file_width > max_file_width
        end,
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        preview = {
          filesize_limit = 0.01, -- Use filesize_hook for files > 10KB
          filesize_hook = function(filepath, bufnr, _)
            local max_lines = 50
            local max_line_width = 200

            local lines = {}
            for line in io.lines(filepath) do
              lines[1 + #lines] = line:sub(0, max_line_width)
              if #lines > max_lines then
                break
              end
            end
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
          end,
        },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      use_default_mappings = false,
      filesystem = {
        group_empty_dirs = true,
      },
      window = {
        auto_expand_width = true,
        position = "left",
        mappings = {
          ["s"] = "toggle_hidden", -- show hidden
          ["?"] = "show_help",
          ["c"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",

          -- Vim like
          ["p"] = "paste_from_clipboard",
          ["/"] = "fuzzy_finder",
          ["r"] = "rename",
          ["o"] = "add",
          ["d"] = "delete",
          ["q"] = "close_window",
          ["<esc>"] = "close_window",

          -- Movement
          ["H"] = "close_all_nodes",
          ["L"] = "expand_all_nodes",
          ["h"] = "close_node",
          ["l"] = {
            function(state)
              local cc = require("neo-tree.sources.common.commands")
              local fs = require("neo-tree.sources.filesystem")
              local renderer = require("neo-tree.ui.renderer")

              local function expand_folders(node)
                if node == nil or node.type ~= "directory" then
                  return
                end

                if node.loaded then
                  if node:has_children() then
                    renderer.focus_node(state, node:get_child_ids()[1])
                  end
                  return
                end

                local parent = state.tree:get_node(node:get_parent_id())
                local childs = parent:get_child_ids()
                local grouped_child = nil

                for i = 1, #childs do
                  if childs[i]:sub(1, #node.id) == node.id then
                    grouped_child = state.tree:get_node(childs[i])
                    break
                  end
                end

                fs.toggle_directory(state, grouped_child, nil, nil, nil, function()
                  expand_folders(grouped_child)
                end)
              end

              cc.open(state, expand_folders)
            end,
            desc = "Open",
          },
        },
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    cond = function()
      return vim.fn.executable("rust-analyzer") == 1
    end,
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            inlayHints = {
              maxLength = 6,
              typeHints = { enable = false },
              chainingHints = { enable = false },
              parameterHints = { enable = false },
              closingBraceHints = { enable = false },
            },
            imports = {
              granularity = { enforce = true, group = "module" },
              group = { enable = false },
              preferPrelude = true,
            },
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=chromium",
          },
        },
      },
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      render_modes = true,
      anti_conceal = { enabled = false },
      heading = {
        width = "block",
        min_width = 100,
        border = true,
        border_virtual = true,
      },
      code = {
        language_name = false,
        style = "normal",
        min_width = 40,
        right_pad = 4,
      },
    },
  },
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader><space>", "<cmd>startinsert | FzfLua files<cr>", desc = "Find Files (Root Dir)" },
    },
  },
}
