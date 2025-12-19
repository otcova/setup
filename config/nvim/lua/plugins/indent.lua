-- Default indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true

-- Show/Set current indentation
local indent_help = vim.trim([[
:Indent help      -- Print :Indent cheatsheet
:Indent           -- Print current indentation
:Indent 4         -- Set indent to 4 spaces
:Indent tab       -- Set indent to tabs
:Indent 4 convert -- Set & Convert indent
:Indent display   -- Toggle display tabs & trailing spaces
]])

vim.api.nvim_create_user_command("I", function(opts)
  vim.cmd("Indent " .. (opts.args or ""))
end, {
  nargs = "?",
  desc = "Alias for :Indent",
})

vim.api.nvim_create_user_command("Indent", function(opts)
  local args = vim.split(vim.trim(opts.args), "%s+")
  if #args == 1 and args[1] == "" then
    args = {}
  end

  if args[1] == "h" or args[1] == "help" then
    vim.notify(indent_help)
    return
  end

  -- Toggle display tabs and trailing spaces
  if args[1] == "d" or args[1] == "display" then
    vim.opt.list = not vim.opt.list:get()
    return
  end

  if #args > 0 then
    -- Parse arg: indent config
    local indent_spaces = false
    if args[1] ~= "t" and args[1] ~= "tab" then
      indent_spaces = tonumber(args[1])
      if not indent_spaces or indent_spaces <= 0 then
        vim.notify(indent_help)
        return
      end
    end

    -- Convert Indent
    if args[2] == "c" or args[2] == "convert" then
      local prev_indent_spaces = false
      if vim.opt_local.expandtab:get() then
        prev_indent_spaces = vim.opt_local.shiftwidth:get()
      end

      if prev_indent_spaces and not indent_spaces then
        local prev_spaces = string.rep(" ", prev_indent_spaces)
        print("Converting from '" .. prev_spaces .. "' to '\\t'")
        vim.cmd("silent! %s/" .. prev_spaces .. "/\\t/g")
      elseif not prev_indent_spaces and indent_spaces then
        local new_spaces = string.rep(" ", indent_spaces)
        print("Converting from '\\t' to '" .. new_spaces .. "'")
        vim.cmd("silent! %s/\\t/" .. new_spaces .. "/g")
      elseif prev_indent_spaces and indent_spaces then
        local prev_spaces = string.rep(" ", prev_indent_spaces)
        local new_spaces = string.rep(" ", indent_spaces)
        print("Converting from '" .. prev_spaces .. "' to '" .. new_spaces .. "'")
        vim.cmd("silent! %s/" .. prev_spaces .. "/" .. new_spaces .. "/g")
      end
    end

    -- Config Indent
    if indent_spaces then
      -- vim.opt_local.tabstop = indent_spaces
      vim.opt_local.shiftwidth = indent_spaces
      vim.opt_local.expandtab = true
    else
      -- vim.opt_local.tabstop = 8 -- May want 8 as default when tabs (vim standard)
      vim.opt_local.expandtab = false
    end
  end

  -- Show Indent
  local ts = vim.opt_local.tabstop:get()
  local sw = vim.opt_local.shiftwidth:get()
  local et = vim.opt_local.expandtab:get()

  message = "Indent: " .. (et and (sw .. " spaces") or "tabs")
  if not et or ts ~= 8 then
    message = message .. " (tab size " .. ts .. ")"
  end
  print(message)
end, {
  nargs = "?",
  desc = "Set indentation: number for spaces, 'tab' or 't' for tabs; no args shows current",
})

return {
  -- Autodetect indetnation of buffer
  -- (Looks for files in same directory with same extension for blank/new files)
  {
    --"Darazaki/indent-o-matic",
    "tpope/vim-sleuth",
    lazy = false,
  }
}
