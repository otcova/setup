require("init_lazy")

-- Common keymaps
vim.keymap.set("n", "<c-k>", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", "<cmd>silent qa<CR>")
vim.keymap.set({"n", "v"}, "<leader>j", "<esc>40jzt")
vim.keymap.set({"n", "v"}, "<leader>k", "<esc>40kzt")
vim.keymap.set({"n", "v"}, "<leader>a", "<cmd>e#<cr>")

vim.opt.scrolloff = 3



