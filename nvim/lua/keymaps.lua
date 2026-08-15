vim.g.mapleader = ","

local map = vim.keymap.set

-- nvim-tree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>")
map("n", "<Leader>n", "<cmd>NvimTreeFindFile<CR>")

-- Telescope
-- Smart file finder: use git_files (instant `git ls-files`) inside a git repo,
-- fall back to find_files elsewhere. Avoids a ~9s recursive walk of huge trees.
map("n", "<Leader>ff", function()
    local builtin = require("telescope.builtin")
    local in_git = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
    if in_git then
        -- show_untracked=true forces `git ls-files --others`, which walks the ENTIRE
        -- worktree (incl. huge ignored dirs like src/.cache) -> ~6s. Drop it: use the
        -- index-only `git ls-files` (~0.05s). Untracked files simply won't appear in ,ff.
        builtin.git_files()
    else
        builtin.find_files()
    end
end)
map("n", "<Leader>fg", "<cmd>Telescope live_grep<CR>")
map("n", "<Leader>fb", "<cmd>Telescope buffers<CR>")
map("n", "<Leader>fh", "<cmd>Telescope help_tags<CR>")

-- Clear search highlight
map("n", "<Leader>h", "<cmd>nohlsearch<CR>")

-- Terminal: open in horizontal split, exit terminal mode with Esc
map("n", "<Leader>t", "<cmd>split | term<CR>")
map("t", "<Esc>", "<C-\\><C-n>")

-- Open current file in TextEdit (macOS)
if vim.fn.has("mac") == 1 then
    map("n", "<F3>", "<cmd>!open -a TextEdit %<CR>")
end
