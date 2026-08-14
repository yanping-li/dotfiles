local opt = vim.opt

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.cindent = true

-- Line length
opt.textwidth = 100

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Display
opt.number = false
opt.wrap = false
opt.scrolloff = 2
opt.laststatus = 2
opt.showmode = true
opt.showcmd = true
opt.ruler = true
opt.title = true
opt.shortmess:append("I")  -- no intro message

-- Splits open below and right
opt.splitbelow = true
opt.splitright = true

-- Encoding
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- No backup/swap clutter; use undofile instead
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Clipboard: sync with OS when not in tmux
if vim.env.TMUX == nil or vim.env.TMUX == "" then
    opt.clipboard = "unnamed"
end

-- Misc
opt.errorbells = false
opt.startofline = false
opt.wildmenu = true
opt.backspace = "indent,eol,start"
opt.list = false
opt.listchars = { tab = ">-", trail = ".", extends = ">", precedes = "<" }
opt.secure = true


-- File type associations
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.json",
    command = "setlocal filetype=json",
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.md",
    command = "setlocal filetype=markdown",
})

-- Open quickfix window automatically after grep
vim.api.nvim_create_augroup("quickfix", { clear = true })
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = "quickfix",
    pattern = "[^l]*",
    command = "cwindow",
})
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = "quickfix",
    pattern = "l*",
    command = "lwindow",
})

-- Silent grep command
vim.api.nvim_create_user_command("Grep", function(opts)
    vim.cmd("silent grep! " .. opts.args .. " | cw | redraw!")
end, { nargs = "+" })
