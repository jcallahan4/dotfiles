-- Side-by-side git diffs with a file panel. Used to review what an agent changed:
--   <leader>gd  working tree vs HEAD          <leader>gD  last commit (the agent's last step)
--   <leader>gr  diff against a rev/tag range   <leader>gh  history of the current file
--   <leader>gH  repo history                   <leader>gc  close
return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Git diff: working tree vs HEAD" },
    { "<leader>gD", "<cmd>DiffviewOpen HEAD~1<CR>", desc = "Git diff: last commit" },
    {
      "<leader>gr",
      function()
        vim.ui.input({ prompt = "Diff range (e.g. run-01..HEAD, baseline): " }, function(rev)
          if rev and rev ~= "" then
            vim.cmd("DiffviewOpen " .. rev)
          end
        end)
      end,
      desc = "Git diff: against a rev or tag range",
    },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Git history: current file" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Git history: repository" },
    { "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "Git diff: close" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = { merge_tool = { layout = "diff3_mixed" } },
  },
}
