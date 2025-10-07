-- Use system clipboard
vim.schedule(function()
	-- Preload the clipboard.vim to prevent it from being sourced on key press
	vim.cmd.runtime("autoload/provider/clipboard.vim")
	vim.opt.clipboard = "unnamedplus"
end)

return {
	-- Extend f, F, t, T to work on multiple lines.
	-- Repeat jump by pressing f, F, t, T again.
	{
		"echasnovski/mini.jump",
		event = "VeryLazy",
		opts = {},
	},
	-- Better around / inside
	-- [q]uotes, [b]raquets, [a]rguments, xml [t]ags, [f]unction call, [a]rguaqent
	-- daq (delete around next quotes) . (repeat)
	-- vala (select around last arg)
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		opts = {},
	},
	-- Surround [a]dd / [d]elete / [r]eplace / [f]ind / [h]ighlight
	-- saiwq (Surround add inside word quotes)
	-- sdb (Surround delete braquets)
	-- srbq (Surround replace braquets quotes)
	-- shnq (Surround highlight next quotes)
	{
		"nvim-mini/mini.surround",
		event = "VeryLazy",
		opts = {},
	},
	-- Auto close braquets / quotes
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		opts = {},
	},
}
