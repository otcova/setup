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
    if indent2_score > indent4_score then
      vim.bo.shiftwidth = 2
      vim.bo.tabstop = 2
    elseif indent4_score > indent2_score then
      vim.bo.shiftwidth = 4
      vim.bo.tabstop = 4
    end
  end,
})

return {
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
              granularity = { enforce = true },
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
      },
    },
  },
}
