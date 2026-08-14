return function()
    require("telescope").setup({
        defaults = {
            layout_strategy = "horizontal",
            layout_config = { preview_width = 0.55 },
            file_ignore_patterns = { "%.git/", "node_modules/" },
        },
    })
end
