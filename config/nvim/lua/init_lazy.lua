-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  -- Colorscheme that will be used when installing plugins.
  install = { colorscheme = { "kanagawa", "habamax" } },
  spec = {
    -- Color scheme
    {
      "rebelot/kanagawa.nvim",
      priority = 1000,
      opts = {
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none"
              }
            }
          }
        }
      },
      init = function()
        vim.cmd.colorscheme("kanagawa")

        vim.api.nvim_set_hl(0, "MiniDiffSignAdd", { fg = "#409050" })
        vim.api.nvim_set_hl(0, "MiniDiffSignChange", { fg = "#308090" })
        vim.api.nvim_set_hl(0, "MiniDiffSignDelete", { fg = "#b04050" })

        vim.api.nvim_set_hl(0, "SignColumn", { fg = "#938aa9", bg = "#262631" })
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#60607d", bg = "#262631" })

        -- Presentation Mode:
        -- vim.api.nvim_set_hl(0, "LineNr", { fg = "#434359", bg = "#262631" })
      end,
    },
    { import = "plugins" },
  },

  -- No lua plugin manager
  rocks = { enabled = false },

  change_detection = { enabled = false },

  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "editorconfig", -- 0.27ms
        "gzip",         -- 0.34ms
        "man",          -- 0.26ms
        "matchit",      -- 1.01ms
        "matchparen",   -- 0.3ms
        "netrwPlugin",  -- 0.98ms
        "osc52",        -- 0.26ms
        "rplugin",      -- 0.31ms
        "shada",        -- 0.24ms
        "spellfile",    -- 0.24ms
        "tarPlugin",    -- 0.3ms
        "tohtml",       -- 0.29ms
        "tutor",        -- 0.21ms
        "zipPlugin",    -- 0.29ms
      },
    },
  },
})
