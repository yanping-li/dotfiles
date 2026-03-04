-- Display
vim.opt.number = false
vim.opt.wrap = false
vim.opt.scrolloff = 2
vim.opt.laststatus = 2
vim.opt.ruler = true
vim.opt.showmode = true
vim.opt.showcmd = true
vim.opt.title = true
vim.opt.shortmess = "atI"
vim.opt.termguicolors = true
vim.cmd("colorscheme desert")

-- Editing
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cindent = true
vim.opt.textwidth = 100
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.binary = true
vim.opt.eol = false

-- Search
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Misc
vim.opt.errorbells = false
vim.opt.startofline = false
vim.opt.wildmenu = true
vim.opt.secure = true
vim.opt.list = false
vim.opt.listchars = { tab = ">-", trail = ".", extends = ">", precedes = "<" }

-- Clipboard (only outside tmux)
if vim.env.TMUX == nil or vim.env.TMUX == "" then
    vim.opt.clipboard:append("unnamed")
end

-- Filetype detection
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.json",
    callback = function()
        vim.bo.filetype = "json"
    end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.md",
    callback = function()
        vim.bo.filetype = "markdown"
    end,
})

-- Strip trailing whitespace on save (replaces DeleteTrailingWhitespace plugin)
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        vim.cmd([[%s/\s\+$//e]])
    end,
})

-- Auto-open QuickFix window after grep
vim.api.nvim_create_augroup("quickfix", { clear = true })
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = "quickfix",
    pattern = "[^l]*",
    callback = function() vim.cmd("cwindow") end,
})
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = "quickfix",
    pattern = "l*",
    callback = function() vim.cmd("lwindow") end,
})

-- Silent grep command that auto-opens QuickFix
vim.api.nvim_create_user_command("Grep", function(opts)
    vim.cmd("silent grep! " .. opts.args .. " | cw | redraw!")
end, { nargs = "+" })
