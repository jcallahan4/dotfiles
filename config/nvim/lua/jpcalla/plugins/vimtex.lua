return {
	"lervag/vimtex",
	lazy = false, -- we don't want to lazy load VimTeX
	-- tag = "v2.15", -- uncomment to pin to a specific release
	init = function()
		-- Ensure VimTeX loads properly
		vim.cmd("filetype plugin indent on")

		-- Enable syntax-related features
		vim.cmd("syntax enable")

		-- init.lua
	end,
	config = function()
		-- Viewer options
		vim.g.vimtex_view_method = "skim"

		-- Generic viewer interface
		-- vim.g.vimtex_view_general_viewer = "okular"
		-- vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"

		-- QuickFix window settings
		vim.g.vimtex_quickfix_ignore_filters = {
			"Underfull \\\\hbox",
			"Overfull \\\\hbox",
			"LaTeX Warning: .+ float specifier changed to",
			"LaTeX hooks Warning",
			'Package siunitx Warning: Detected the "physics" package:',
			"Package hyperref Warning: Token not allowed in a PDF string",
		}

		vim.g.vimtex_quickfix_open_on_warning = 0

		-- Set keymaps
		local keymap = vim.keymap
		keymap.set("n", "<leader>vc", "<cmd>VimtexCompile<CR>", { desc = "Toggle Vim compiler" }) -- toggle file explorer
		keymap.set("n", "<leader>vs", "<cmd>VimtexView<CR>", { desc = "Perform vim forward search" }) -- toggle file explorer on current file
		keymap.set("n", "<leader>vq", "<cmd>copen<CR>", { desc = "Open LaTeX quickfix window" })
		keymap.set("n", "<leader>vQ", "<cmd>cclose<CR>", { desc = "Close LaTeX quickfix window" })
	end,
}
