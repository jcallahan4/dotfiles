-- :Help <topic>  opens ~/dotfiles/help/<topic>.md in a floating window (q closes).
-- :Help alone lists topics. Complements the shell `help` command.
local dir = vim.fn.expand("~/dotfiles/help")

local function topics()
  local t = {}
  for _, f in ipairs(vim.fn.glob(dir .. "/*.md", false, true)) do
    t[#t + 1] = vim.fn.fnamemodify(f, ":t:r")
  end
  return t
end

local function open(topic)
  if topic == nil or topic == "" then
    vim.notify(":Help <topic>  ->  " .. table.concat(topics(), ", "), vim.log.levels.INFO)
    return
  end
  local path = dir .. "/" .. topic .. ".md"
  if vim.fn.filereadable(path) == 0 then
    vim.notify("no help topic '" .. topic .. "' (" .. table.concat(topics(), ", ") .. ")", vim.log.levels.WARN)
    return
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(path))
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  local width = math.min(100, vim.o.columns - 6)
  local height = math.min(vim.api.nvim_buf_line_count(buf) + 2, vim.o.lines - 6)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", width = width, height = height,
    row = math.floor((vim.o.lines - height) / 2), col = math.floor((vim.o.columns - width) / 2),
    style = "minimal", border = "rounded", title = " help: " .. topic .. " ", title_pos = "center",
  })
  vim.wo[win].wrap = true
  vim.wo[win].conceallevel = 2
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, nowait = true })
end

vim.api.nvim_create_user_command("Help", function(o) open(o.args) end, {
  nargs = "?",
  complete = function() return topics() end,
  desc = "Research workflow help (~/dotfiles/help)",
})
