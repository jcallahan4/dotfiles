return {
	"nvim-treesitter/nvim-treesitter",
	-- The legacy `master` branch does not support Neovim 0.12+. The rewritten
	-- `main` branch is the supported path going forward.
	branch = "main",
	-- Load eagerly so the FileType autocmd below is registered before the first
	-- FileType event fires (otherwise highlighting can be skipped for the file
	-- you launched nvim with).
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local ts = require("nvim-treesitter")

		-- Use the default install_dir (stdpath('data')/site).
		ts.setup()

		-- Parsers to install. Runs asynchronously and is a no-op for parsers
		-- that are already installed.
		ts.install({
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
		})

		-- Filetypes we never want treesitter for (vimtex owns tex).
		local disable_for = { tex = true, latex = true, plaintex = true }

		---------------------------------------------------------------------
		-- Incremental selection
		--
		-- The `main` branch removed the built-in incremental_selection module,
		-- so this reimplements the behaviour we had on `master`:
		--   <C-space> (normal)  -> select node under cursor
		--   <C-space> (visual)  -> expand to parent node
		--   <bs>      (visual)  -> shrink to previous node
		---------------------------------------------------------------------
		local stacks = {} -- bufnr -> { TSNode, ... } (top of stack = current)

		local function range_eq(a, b)
			return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4]
		end

		-- Visually select a treesitter range (0-based rows/cols, end exclusive).
		local function visual_select(range)
			local srow, scol, erow, ecol = range[1], range[2], range[3], range[4]
			if ecol == 0 then
				-- Range ends at the very start of erow -> last byte of prev line.
				erow = erow - 1
				ecol = #vim.fn.getline(erow + 1)
			end
			vim.fn.setpos("'<", { 0, srow + 1, scol + 1, 0 })
			vim.fn.setpos("'>", { 0, erow + 1, ecol, 0 })
			vim.cmd("normal! gv")
		end

		local function init_selection()
			local buf = vim.api.nvim_get_current_buf()
			local node = vim.treesitter.get_node()
			if not node then
				return
			end
			stacks[buf] = { node }
			visual_select({ node:range() })
		end

		local function node_incremental()
			local buf = vim.api.nvim_get_current_buf()
			local st = stacks[buf]
			if not st or #st == 0 then
				return init_selection()
			end
			local node = st[#st]
			local cur = { node:range() }
			local parent = node:parent()
			-- Skip ancestors whose range is identical to the current node.
			while parent and range_eq(cur, { parent:range() }) do
				parent = parent:parent()
			end
			if parent then
				table.insert(st, parent)
				visual_select({ parent:range() })
			end
		end

		local function node_decremental()
			local buf = vim.api.nvim_get_current_buf()
			local st = stacks[buf]
			if not st or #st <= 1 then
				return
			end
			table.remove(st)
			visual_select({ st[#st]:range() })
		end

		-- Enable treesitter features per buffer.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("jpcalla_treesitter", { clear = true }),
			callback = function(args)
				local buf = args.buf
				local ft = vim.bo[buf].filetype
				if ft == "" or disable_for[ft] then
					return
				end

				-- Resolve the parser for this filetype and bail if it isn't
				-- available/installed (keeps this quiet for unsupported fts).
				local lang = vim.treesitter.language.get_lang(ft) or ft
				if not pcall(vim.treesitter.start, buf, lang) then
					return
				end

				-- Treesitter-based indentation (experimental upstream).
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

				-- Incremental selection keymaps (buffer-local).
				local opts = { buffer = buf, silent = true }
				vim.keymap.set("n", "<C-space>", init_selection, opts)
				vim.keymap.set("x", "<C-space>", node_incremental, opts)
				vim.keymap.set("x", "<bs>", node_decremental, opts)
			end,
		})

		-- autotag previously hooked into nvim-treesitter's config; on `main` it
		-- is configured standalone.
		require("nvim-ts-autotag").setup()
	end,
}
