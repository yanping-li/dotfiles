return function()
    require("telescope").setup({
        defaults = {
            layout_strategy = "horizontal",
            layout_config = { preview_width = 0.55 },
            file_ignore_patterns = { "%.git/", "node_modules/", "%.o$", "%.pic$", "%.a$", "%.so$", "/%.bld/" },
        },
        pickers = {
            find_files = { disable_devicons = true },
            live_grep  = { disable_devicons = true },
            buffers    = { disable_devicons = true },
        },
    })
end
