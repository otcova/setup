if vim.loop.os_uname().sysname:find("Windows") then
  vim.opt.shell = "powershell"
  vim.opt.shellcmdflag = "-command"
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = {
        disable = function(_, buf)
          local max_file_size = 1024 * 1024 -- 1 MB
          local max_file_width = 10 * 1024 -- 10KB

          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
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
          ["<cr>"] = function() end,
          ["s"] = "toggle_hidden",
          ["/"] = "fuzzy_finder",
          ["H"] = "close_all_nodes",
          ["L"] = "expand_all_nodes",
          ["h"] = "close_node",
          ["l"] = function(state)
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
}
