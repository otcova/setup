require("init_lazy")

vim.opt.scrolloff = 3

local function open_terminal(repeat_cmd)
    if vim.bo.buftype == "terminal" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
        vim.cmd("b#")
        return
    end

    -- Check if there's an existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            vim.api.nvim_set_current_buf(buf)
            vim.cmd("startinsert!")
            if repeat_cmd then
                vim.api.nvim_input("<up><cr><c-\\><c-n>0")
            end
            return
        end
    end

    vim.cmd("terminal")
    if repeat_cmd then
        vim.defer_fn(function()
            vim.cmd("startinsert!")
            vim.api.nvim_input("<up><cr><c-\\><c-n>0")
        end, 100)
    else
        vim.cmd("startinsert!")
    end
end

local opts = {noremap=true, silent=true}

vim.keymap.set("n", "<c-h>", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
vim.keymap.set("n", "<leader>q", "<cmd>silent qa<CR>", opts)
vim.keymap.set({"n", "v"}, "<leader>a", "<cmd>b#<cr>", opts)

vim.keymap.set("n", "<c-j>", "<c-e>", opts)
vim.keymap.set("n", "<c-k>", "<c-y>", opts)

vim.keymap.set("t", "<esc>", "<c-\\><c-n>", opts)
vim.keymap.set({"n", "t"}, "<c-e>", open_terminal, opts)
vim.keymap.set("n", "E", function() open_terminal(true) end, opts)

vim.keymap.set("n", "dl", "2x", opts)



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



local function to_snake_case(word)
    word = word:gsub("-", "_")
    word = word:gsub("(%l)(%u)", "%1_%2")
    return word:lower()
end

local function to_pascal_case(word)
    word = word:gsub("([_%-%s])(%a)", function(_, c) return c:upper() end)
    return word:gsub("^%l", string.upper)
end

local function change_cursor_word(case)
    local word = vim.fn.expand("<cword>")
    if not word or word == "" then return end

    local snake = case(word)
    if snake == word then return end

    vim.cmd("normal! ciw" .. snake)
end

vim.keymap.set("n", "cs", function() change_cursor_word(to_snake_case) end)
vim.keymap.set("n", "cp", function() change_cursor_word(to_pascal_case) end)
