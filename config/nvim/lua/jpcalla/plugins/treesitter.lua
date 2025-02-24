return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		-- list of languages to disable tree-sitter for
		local disable_for = { "tex" }

		-- function to check if a language should be disabled
		local function should_disable(lang, buf)
			return vim.tbl_contains(disable_for, lang)
		end

		-- configure treesitter
		treesitter.setup({
			-- enable syntax highlighting
			highlight = {
				enable = true,
				disable = should_disable,
			},
			-- enable indentation
			indent = {
				enable = true,
				disable = should_disable,
			},
			-- enable autotagging (w/ nvim-ts-autotag plugin)
			autotag = {
				enable = true,
				disable = should_disable,
			},
			-- ensure these language parsers are installed
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"markdown",
				"markdown_inline",
				"svelte",
				"graphql",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"c",
				"python",
			},
			incremental_selection = {
				enable = true,
				disable = should_disable,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
