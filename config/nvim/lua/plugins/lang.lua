local show_sign_column = function(buf)
  local ft = vim.bo[buf].filetype
  local bt = vim.bo[buf].buftype

  local scl = "no"
  if bt == "" and ft ~= "markdown" and ft ~= "" then
    scl = "yes"
    -- Check if the window has line numbers enabled
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      if not vim.wo[win].number and not vim.wo[win].relativenumber then
        scl = "no"
        break
      end
    end
  end

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win].signcolumn = scl
  end
end

-- Enable sign column for buffers that are not markdown, and have lineNr
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    show_sign_column(args.buf)
    vim.schedule(function() show_sign_column(args.buf) end)
  end
})

vim.diagnostic.config({
  underline = false,
  severity_sort = true,
})

vim.keymap.set("n", "<c-k>", vim.diagnostic.open_float)

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'wgsl' },
  callback = function() vim.treesitter.start() end,
})

return {
  -- Default condifuration for many LSPs
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "LspInfo",
    init = function()
      -- vim.lsp.config("*", {
      --   capabilities = {
      --     textDocument = {
      --       semanticTokens = {
      --         multilineTokenSupport = true,
      --       }
      --     }
      --   },
      -- })
    end,
  },
  -- `lazydev` configures Lua LSP for the Neovim config, runtime and plugins
  -- used for completion, annotations and signatures of Neovim apis
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  -- Auto formatting
  {
    "stevearc/conform.nvim",
    lazy = true,
    cmd = "ConformInfo",
    opts = {},
    keys = {
      {
        "<leader>w",
        function()
          require("conform").format({
            lsp_fallback = true,
            timeout_ms = 500,
          })
          vim.cmd("update")
        end,
        mode = { "n", "v" },
      },
    },
  },
  -- To install parsers
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    --event = { "VeryLazy", "BufReadPre", "BufNewFile" },
    lazy = false,
    build = ":TSUpdate",
    opts = {
      highlight = {
        enable = true,
      },
      ensure_installed = {
        "c",
        "typescript",
        "bash",
        "regex",
        "wgsl",
      },
      auto_install = true,
    },
  },
  -- To install binaries of LSPs, Formatters & DAPs
  {
    "mason-org/mason.nvim",
    event = "VeryLazy",
    cmd = "Mason",
    opts = {},
    init = function()
      local ensure_installed = {
        'tree-sitter-cli',
      }

      local registry = require("mason-registry")
      for _, pkg_name in ipairs(ensure_installed) do
        local pkg = registry.get_package(pkg_name)
        if not pkg:is_installed() then
          pkg:install()
        end
      end
    end,
  },
  -- Add mason LSP binary paths to nvim lsp-config
  -- Use `:LspInstall` to install a LSP for the current buffer.
  {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    opts = {
      -- Call vim.lsp.enable("installed-lsp-name") for each LSP
      automatic_enable = true,
    },
  },
  -- Autocompletion <c-n> <c-p> <c-l>
  -- Show signature "K"
  {
    "saghen/blink.cmp",
    event = "VeryLazy",
    version = "1.*",
    opts = {
      fuzzy = { implementation = "prefer_rust" },
      keymap = {
        preset = "none",
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<C-y>'] = { 'select_and_accept' },
        ['<C-l>'] = { 'select_and_accept' },
        ['<C-h>'] = { 'select_and_accept' },

        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      },
    },
  },
}
