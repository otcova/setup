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
					if stats and ok then
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
				buffer_previewer_maker = function(filepath, bufnr, opts)
					local max_file_size = 10 * 1024 -- 10 KB

					local ok, stats = pcall(vim.loop.fs_stat, vim.fn.expand(filepath))
					local file_size = 0
					if stats and ok then
						file_size = stats.size
					end

					local highlight = file_size < max_file_size
					local previewers = require("telescope.previewers")
					previewers.buffer_previewer_maker(filepath, bufnr, { use_ft_detect = highlight })
				end,
			},
		},
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		opts = {
			filesystem = {
				group_empty_dirs = true,
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
