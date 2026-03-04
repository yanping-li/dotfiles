require("lazy").setup({

    -- File tree (replaces NERDTree)
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- requires a Nerd Font
        config = function()
            require("nvim-tree").setup()
            -- Close nvim when nvim-tree is the last window
            vim.api.nvim_create_autocmd("BufEnter", {
                nested = true,
                callback = function()
                    local wins = vim.api.nvim_list_wins()
                    if #wins == 1 then
                        local buf = vim.api.nvim_win_get_buf(wins[1])
                        if vim.bo[buf].filetype == "NvimTree" then
                            vim.cmd("quit")
                        end
                    end
                end,
            })
        end,
    },

    -- Auto pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },

    -- Google search from vim
    { "szw/vim-g" },

    -- Draw ASCII art
    { "vim-scripts/DrawIt" },

    -- Unix file commands (:Rename, :Delete, :Move, etc.)
    { "tpope/vim-eunuch" },

    -- Syntax highlighting (replaces vim-polyglot)
    -- New nvim-treesitter: no setup() needed; parsers auto-highlight when installed
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "bash", "c", "go", "json", "lua",
                "markdown", "python", "javascript",
            })
        end,
    },

    -- Surround motions (cs/ds/ysiw)
    { "tpope/vim-surround" },

    -- Fuzzy finder (replaces ctrlp)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<C-p>", ":Telescope find_files<CR>",  desc = "Find files" },
            { "<Leader>b", ":Telescope buffers<CR>", desc = "Buffers" },
            { "<Leader>g", ":Telescope live_grep<CR>", desc = "Live grep (requires ripgrep)" },
        },
    },

    -- Python indent text object
    { "michaeljsmith/vim-indent-object" },

    -- Go development
    {
        "fatih/vim-go",
        config = function()
            vim.g.go_def_mode = "gopls"
            vim.g.go_info_mode = "gopls"
            vim.g.go_list_type = "quickfix"
            vim.g.go_version_warning = 0
        end,
    },

    -- Linting (replaces syntastic)
    {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                go = { "golangcilint" },
                python = { "pylint" },
            }
            vim.api.nvim_create_autocmd("BufWritePost", {
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end,
    },

})
