require("init_lazy")

-- Common keymaps
vim.keymap.set("n", "<c-k>", vim.diagnostic.open_float)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "<leader>q", "<cmd>silent qa<CR>")
vim.keymap.set({"n", "v"}, "<leader>a", "<cmd>e#<cr>")

vim.opt.scrolloff = 3

-- Slide Scroll
vim.keymap.set({"n", "v"}, "<leader>j", function()
    local line = vim.fn.line(".")
    local page_line = math.floor(line / 100 + 1) * 100
    vim.cmd("normal! " .. math.max(1, page_line - line) .. "jzt")
end)
vim.keymap.set({"n", "v"}, "<leader>k", function()
    local line = vim.fn.line(".")
    local page_line = math.floor(line / 100 - 1) * 100
    vim.cmd("normal! " .. math.max(1, line - page_line) .. "kzt")
end)




