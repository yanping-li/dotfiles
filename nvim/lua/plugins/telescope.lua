return function()
    require("telescope").setup({
        defaults = {
            layout_strategy = "horizontal",
            layout_config = { preview_width = 0.55 },
            file_ignore_patterns = { "%.git/", "%.cache/", "%.idx$", "node_modules/", "%.o$", "%.pic$", "%.a$", "%.so$", "/%.bld/" },
        },
        pickers = {
            find_files = { disable_devicons = true },
            git_files  = { disable_devicons = true },
            live_grep  = { disable_devicons = true },
            buffers    = { disable_devicons = true },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
        },
    })

    -- C-based fuzzy sorter (huge speedup on large candidate lists). Safe no-op if the
    -- native module failed to build.
    pcall(function() require("telescope").load_extension("fzf") end)
end
