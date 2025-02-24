return {
	"L3MON4D3/LuaSnip",
	config = function()
		local luasnip = require("luasnip")

		luasnip.config.set_config({
			-- enable autotiggered snippets
			enable_autosnippets = true,
			-- Use Tab (or some other key if preferred) to trigger visual selection
			store_selection_keys = "<Tab>",
		})

		-- you can add more luasnip confs here if needed
		-- Keep rogue friendly snippets out
		require("luasnip.loaders.from_vscode").load({ exclude = { "tex", "latex" } })

		-- expand or jump in insert mode
		vim.api.nvim_set_keymap(
			"i",
			"<Tab>",
			"luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'",
			{ silent = true, expr = true }
		)

		-- jump forward through tabstops in visual mode
		vim.api.nvim_set_keymap(
			"s",
			"<Tab>",
			"luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'",
			{ silent = true, expr = true }
		)

		-- jump backward through snippet tabstops with Shift-Tab
		vim.api.nvim_set_keymap(
			"i",
			"<S-Tab>",
			"luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'",
			{ silent = true, expr = true }
		)
		vim.api.nvim_set_keymap(
			"s",
			"<S-Tab>",
			"luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'",
			{ silent = true, expr = true }
		)
		-- load all snippets from the nvim/LuaSnip directory at startup
		require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/LuaSnip/" } })

		-- lazy-load snippets, only load when required (optional)
		-- require("luasnip.loaders.from_lua").lazy_load({ paths = { "~/.config/nvim/LuaSnip/" } })
	end,
}
