vim.g.mapleader = ","

local map = vim.keymap.set

-- nvim-tree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>")
map("n", "<Leader>n", "<cmd>NvimTreeFindFile<CR>")

-- Telescope
map("n", "<Leader>ff", "<cmd>Telescope find_files<CR>")
map("n", "<Leader>fg", "<cmd>Telescope live_grep<CR>")
map("n", "<Leader>fb", "<cmd>Telescope buffers<CR>")
map("n", "<Leader>fh", "<cmd>Telescope help_tags<CR>")

-- Clear search highlight
map("n", "<Leader>h", "<cmd>nohlsearch<CR>")

-- Open current file in TextEdit (macOS)
if vim.fn.has("mac") == 1 then
    map("n", "<F3>", "<cmd>!open -a TextEdit %<CR>")
end
