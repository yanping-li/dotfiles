local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {

    -- Colorscheme
    {
        "Mofiqul/vscode.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("vscode").setup({ style = "dark", color_overrides = { vscBack = "#000000" } })
            vim.cmd("colorscheme vscode")
        end,
    },

    -- Devicons (required by several plugins; all glyphs disabled)
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({ default = false, override = {} })
        end,
    },

    -- File tree
    {
        "nvim-tree/nvim-tree.lua",
        config = function() require("plugins.ui").nvim_tree() end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        config = function() require("plugins.ui").lualine() end,
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function() require("plugins.telescope")() end,
    },

    -- Syntax / treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function() require("plugins.treesitter")() end,
    },

    -- LSP (native nvim 0.11 API)
    {
        "williamboman/mason.nvim",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function() require("plugins.lsp")() end,
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        event = "InsertEnter",
        config = function() require("plugins.lsp").cmp() end,
    },

    -- Pairs
    { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

    -- Surround (cs/ds/ysiw/yss)
    { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

    -- Go
    {
        "fatih/vim-go",
        ft = "go",
        init = function()
            vim.g.go_def_mode = "gopls"
            vim.g.go_info_mode = "gopls"
            vim.g.go_list_type = "quickfix"
            vim.g.go_version_warning = 0
        end,
    },

    -- Markdown inline rendering
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = "markdown",
        opts = {},
    },

    -- cscope: raw-text symbol search. Complements clangd -- finds things the
    -- AST-based LSP structurally can't, e.g. a bare identifier that only ever
    -- appears as a token-pasting macro argument (PAN_COUNTER_INC(foo) --
    -- clangd only ever sees the EXPANDED PAN_COUNTER_foo after preprocessing;
    -- cscope sees the literal source text). Neovim dropped native :cscope/:cs
    -- support (unlike Vim), hence the plugin. Database: generate with
    -- `cscope-prepare` (~/bin/cscope-prepare), run from a worktree's src/ dir.
    {
        "dhananjaylatkar/cscope_maps.nvim",
        ft = { "c", "cpp" },
        opts = {
            -- disabled: the plugin's default <leader>ca ("find assignments")
            -- collides with the LSP code-action keymap in plugins/lsp.lua.
            disable_maps = true,
            cscope = {
                db_file = "./cscope.out",
                picker = "quickfix",
            },
        },
        config = function(_, opts)
            require("cscope_maps").setup(opts)
            local map = vim.keymap.set
            local function find(op) return "<cmd>CsPrompt " .. op .. "<CR>" end
            map("n", "<Leader>cs", find("s"), { desc = "cscope: find symbol" })
            map("n", "<Leader>cg", find("g"), { desc = "cscope: find global definition" })
            map("n", "<Leader>cc", find("c"), { desc = "cscope: find callers" })
            map("n", "<Leader>cd", find("d"), { desc = "cscope: find callees" })
            map("n", "<Leader>ct", find("t"), { desc = "cscope: find text" })
            map("n", "<Leader>ce", find("e"), { desc = "cscope: egrep pattern" })
            map("n", "<Leader>cf", find("f"), { desc = "cscope: find file" })
            map("n", "<Leader>ci", find("i"), { desc = "cscope: find files including" })
        end,
    },

    -- Unix helpers (:Rename, :Delete, :Move, etc.)
    { "tpope/vim-eunuch" },

    -- Indent text object (ai / ii)
    { "michaeljsmith/vim-indent-object" },

    -- Trailing whitespace removal
    { "ntpeters/vim-better-whitespace", config = function()
        vim.g.better_whitespace_enabled = 1
        vim.g.better_whitespace_ctermcolor = '238'
        vim.g.better_whitespace_guicolor = '#3a3a3a'
        vim.g.strip_whitespace_on_save = 1
        vim.g.strip_whitespace_confirm = 0
    end },
}

local opts = {
    ui = {
        icons = {
            cmd        = "[cmd]",
            config     = "[cfg]",
            event      = "[evt]",
            favorite   = "*",
            ft         = "[ft]",
            init       = "[init]",
            import     = "[imp]",
            keys       = "[key]",
            lazy       = "[lazy]",
            loaded     = "[on]",
            not_loaded = "[off]",
            plugin     = "[pkg]",
            runtime    = "[rt]",
            require    = "[req]",
            source     = "[src]",
            start      = "[start]",
            task       = "[!]",
            list       = { "-", ">", "*", "~" },
        },
    },
}

require("lazy").setup(plugins, opts)
