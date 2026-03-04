-- File tree toggle (nvim-tree)
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<Leader>n", ":NvimTreeFindFile<CR>", { silent = true })

-- Paste mode toggle
vim.keymap.set("n", "<F2>", ":set invpaste paste?<CR>")

-- Open current file in TextEdit (macOS)
if vim.fn.has("mac") == 1 then
    vim.keymap.set("n", "<F3>", ":!open -a TextEdit %<CR>")
end
