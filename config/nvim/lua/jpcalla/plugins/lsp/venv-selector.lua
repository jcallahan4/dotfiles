return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-dap",
		"mfussenegger/nvim-dap-python",
		{ "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
	},
	lazy = false,
	branch = "regexp",
	config = function()
		-- Debug prints
		local conda_path = vim.fn.expand("~/miniforge3")
		local envs_path = vim.fn.expand("~/miniforge3/envs")

		require("venv-selector").setup({
			anaconda_base_path = conda_path,
			anaconda_envs_path = envs_path,
			search_venv_managers = true,
			telescope_window = {
				width = 0.8,
				height = 0.9,
				preview_height = 0.4,
				title = "Virtual Environments",
			},
			settings = {
				search = {
					my_venvs = {
						command = "fd python$ ~/miniforge3/envs",
					},
				},
			},
		})
	end,
	keys = {
		{ "<leader>as", "<cmd>VenvSelect<cr>" },
	},
}
