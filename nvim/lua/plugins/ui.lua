local M = {}

function M.nvim_tree()
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "#000000" })
            vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "#000000" })
            vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { bg = "#000000", fg = "#000000" })
        end,
    })
    vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "#000000" })
    vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "#000000" })
    require("nvim-tree").setup({
        actions = { open_file = { quit_on_open = false } },
        view = { width = { min = 30, max = 60, padding = 2 } },
        renderer = {
            group_empty = true,
            icons = {
                web_devicons = { file = { enable = false }, folder = { enable = false } },
                show = {
                    file = false,
                    folder = false,
                    folder_arrow = true,
                    git = false,
                },
                glyphs = {
                    folder = { arrow_open = "v", arrow_closed = ">" },
                    git = {
                    unstaged  = "M",
                    staged    = "S",
                    unmerged  = "U",
                    renamed   = "R",
                    untracked = "?",
                    deleted   = "D",
                    ignored   = "I",
                },
                },
            },
        },
        filters = { dotfiles = false },
    })
end

function M.lualine()
    require("lualine").setup({
        options = {
            theme = "vscode",
            icons_enabled = false,
            section_separators = "",
            component_separators = "|",
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
        },
    })
end

return M
