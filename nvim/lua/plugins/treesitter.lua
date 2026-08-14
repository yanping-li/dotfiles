return function()
    require("nvim-treesitter.config").setup({
        ensure_installed = { "lua", "python", "go", "bash", "json", "markdown", "c" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
    })
end
