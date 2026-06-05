return {
    "nvim-lua/plenary.nvim", -- lua functions that many plugins use
    {
        "christoomey/vim-tmux-navigator", -- tmux & split window navigation
        config = function()
            local keymap = vim.keymap
            -- arrow keys switch windows (left ctrl+hjkl -> arrows via Karabiner)
            keymap.set("n", "<Left>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Window left" })
            keymap.set("n", "<Down>", "<cmd>TmuxNavigateDown<CR>", { desc = "Window down" })
            keymap.set("n", "<Up>", "<cmd>TmuxNavigateUp<CR>", { desc = "Window up" })
            keymap.set("n", "<Right>", "<cmd>TmuxNavigateRight<CR>", { desc = "Window right" })
        end,
    },
}
