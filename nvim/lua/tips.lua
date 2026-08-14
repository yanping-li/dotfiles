local tips = {
    "LSP: Put cursor on a function and press 'K' — it shows the docs/signature inline.",
    "LSP: Press 'gd' on any symbol to jump to where it's defined.",
    "LSP: Press 'gr' to see everywhere a symbol is used across the project.",
    "LSP: '<Leader>rn' renames a symbol everywhere in the project at once.",
    "LSP: '<Leader>ca' shows fixes nvim can apply — like auto-importing a missing package.",
    "LSP: Red underlines are errors, yellow are warnings. '<Leader>e' explains the one under cursor.",
    "LSP: '[d' goes to the previous diagnostic, ']d' goes to the next one.",
    "Telescope: '<Leader>ff' fuzzy-finds files, '<Leader>fg' searches file contents.",
    "Telescope: '<Leader>fb' lists open buffers, '<Leader>fh' searches help tags.",
    "Treesitter: ':InspectTree' shows the syntax tree of the current file.",
    "Terminal: ',t' opens a terminal split. 'Esc' exits terminal mode.",
    "Terminal: '<C-w>l' moves from terminal to the right window.",
    "Lazy: ':Lazy' opens the plugin manager. 'S' inside it syncs all plugins.",
    "Lazy: ':Lazy update' updates all plugins to their latest versions.",
    "nvim-tree: '<C-n>' toggles the file tree. '<Leader>n' reveals the current file.",
    "nvim-tree: 'a' creates a file, 'd' deletes, 'r' renames inside nvim-tree.",
    "':checkhealth' diagnoses LSP, treesitter, and plugin issues.",
    "':TSInstall <lang>' installs a treesitter grammar for a language.",
    "':Mason' opens the LSP server manager. 'i' installs a server.",
    "Surround: 'cs\"'' changes double quotes to single. 'ds\"' deletes quotes.",
    "Surround: 'ysiw)' wraps the word under cursor in parentheses.",
    "':lua vim.inspect(vim.lsp.get_clients())' lists active LSP clients.",
    "In nvim, 'vim.keymap.set' replaces 'nnoremap' — more readable and powerful.",
    "'<C-w>=' makes all splits equal size. '<C-w>|' maximizes the current split.",
    "':e %:h<Tab>' opens the directory of the current file.",
    "'gf' opens the file under cursor. Works great with import paths.",
    "'<C-o>' jumps back in the jump list, '<C-i>' jumps forward.",
    "':noa w' saves without triggering autocommands (e.g. skips whitespace strip).",
}

local function show_tip()
    math.randomseed(os.time())
    local tip = tips[math.random(#tips)]
    vim.notify("nvim tip: " .. tip, vim.log.levels.INFO, { title = "Tip of the Day" })
end

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.defer_fn(show_tip, 500)
    end,
})
