if vim.uv.os_uname().sysname:find("Windows") then
  vim.opt.shell = "powershell"
  vim.opt.shellcmdflag = "-command"
end

-- Color unused code
vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { link = "DiagnosticUnnecessary" })

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
    if indent2_score > indent4_score then
      vim.bo.shiftwidth = 2
      vim.bo.tabstop = 2
    elseif indent4_score > indent2_score then
      vim.bo.shiftwidth = 4
      vim.bo.tabstop = 4
    end
  end,
})

----------------------------------------
----------------------------------------

local function create_invisible_split()
  local blank_buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("modifiable", false, { buf = blank_buffer })

  local win = vim.api.nvim_open_win(blank_buffer, false, { split = "left" })

  local opts = { win = win }
  vim.api.nvim_set_option_value("number", false, opts)
  vim.api.nvim_set_option_value("relativenumber", false, opts)
  vim.api.nvim_set_option_value("signcolumn", "no", opts)
  vim.api.nvim_set_option_value("cursorline", false, opts)

  return win
end

local left_win = nil
local right_win = nil

-- Returns the win_id after the possible creation / deletion
-- `position` must be H (left-most) or L (right-most)
local function set_pad_window(win, width, position)
  if win ~= nil and not vim.api.nvim_win_is_valid(win) then
    win = nil
  end

  if width <= 0 then
    if win ~= nil then
      vim.api.nvim_win_close(win, false)
    end
    return nil
  end

  if win == nil then
    win = create_invisible_split()

    vim.api.nvim_win_call(win, function()
      vim.api.nvim_command("wincmd " .. position)
    end)
  end

  vim.api.nvim_win_set_width(win, width)
  return win
end

local function is_floating(win_id)
  local config = vim.api.nvim_win_get_config(win_id)
  return not config.relative or config.relative ~= ""
end

local function set_padding(content_window)
  local window_width = 110
  local pad_width = vim.o.columns - window_width
  local left_pad = math.floor(pad_width / 2)
  local right_pad = math.ceil(pad_width / 2)

  left_win = set_pad_window(left_win, left_pad, "H")
  right_win = set_pad_window(right_win, right_pad, "L")

  -- In case of window creation, the sizes migth have been changed
  left_win = set_pad_window(left_win, left_pad, "H")
  vim.api.nvim_win_set_width(content_window, window_width)
  right_win = set_pad_window(right_win, right_pad, "L")
end

local function remove_padding()
  left_win = set_pad_window(left_win, 0, "H")
  right_win = set_pad_window(right_win, 0, "L")
end

local function pad_windows()
  local windows = vim.api.nvim_tabpage_list_wins(0) -- Get all windows in the current tabpage

  local content_window = nil
  local content_window_col = nil

  for _, window in ipairs(windows) do
    if window ~= left_win and window ~= right_win and not is_floating(window) then
      if content_window == nil or content_window_col == nil then
        content_window = window
        content_window_col = vim.api.nvim_win_get_position(window)[2]
      elseif content_window_col == vim.api.nvim_win_get_position(window)[2] then
      -- This means that the window is a horizontal split of content_window.
      -- We will ignore it.
      else
        remove_padding()
        return
      end
    end
  end

  if content_window == nil then
    local buffer = vim.api.nvim_create_buf(false, true)
    content_window = vim.api.nvim_open_win(buffer, true, { split = "right" })
    local opts = { win = content_window }
    vim.api.nvim_set_option_value("number", true, opts)
    vim.api.nvim_set_option_value("relativenumber", true, opts)
    vim.api.nvim_set_option_value("signcolumn", "yes", opts)
    vim.api.nvim_set_option_value("cursorline", true, opts)
  end

  set_padding(content_window)
end

-- Returns the win_id after the possible deletion
-- where must be h (left) or l (right)
local function redirect_focus(win, where)
  if vim.api.nvim_get_current_win() ~= win then
    return win
  end

  vim.cmd("wincmd " .. where)

  if vim.api.nvim_get_current_win() ~= win then
    return win
  end

  vim.api.nvim_win_close(win, false)
  return nil
end

-- Redirect focus
vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    left_win = redirect_focus(left_win, "l")
    right_win = redirect_focus(right_win, "h")
  end,
})

vim.api.nvim_create_autocmd({ "WinNew", "WinClosed", "VimResized", "WinResized" }, {
  callback = function()
    if vim.api.nvim_win_get_config(0).relative == "" then
      pad_windows()
    end
  end,
})

pad_windows()

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
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ reveal = true, toggle = true, dir = LazyVim.root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
    },
    opts = {
      use_default_mappings = false,
      filesystem = {
        group_empty_dirs = true,
      },
      window = {
        auto_expand_width = true,
        position = "float",
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
