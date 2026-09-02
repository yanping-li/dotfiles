local M = {}

function M.cmp()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
        snippet = {
            expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                else fallback() end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                else fallback() end
            end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
        }, {
            { name = "buffer" },
            { name = "path" },
        }),
    })
end

-- Height of the quickfix window that 'gr' (references) opens. nvim's built-in
-- handler hardcodes a bare 'botright copen' (default 10 lines), so override the
-- list handler to pass an explicit height. Scoped to references only, so the
-- cscope picker keeps its own window sizing.
local REFERENCES_QF_HEIGHT = 20

local function references_sized()
    vim.lsp.buf.references(nil, {
        on_list = function(list)
            vim.fn.setqflist({}, " ", list)
            vim.cmd("botright copen " .. REFERENCES_QF_HEIGHT)
        end,
    })
end

local function on_attach(args)
    local bufnr = args.buf
    local map = function(keys, func)
        vim.keymap.set("n", keys, func, { buffer = bufnr })
    end
    map("gd", vim.lsp.buf.definition)
    map("gr", references_sized)
    map("K", vim.lsp.buf.hover)
    map("<Leader>rn", vim.lsp.buf.rename)
    map("<Leader>ca", vim.lsp.buf.code_action)
    map("<Leader>e", vim.diagnostic.open_float)
    map("[d", vim.diagnostic.goto_prev)
    map("]d", vim.diagnostic.goto_next)
end

function M.setup()
    require("mason").setup()
    require("mason-lspconfig").setup({
        ensure_installed = {},
        automatic_installation = false,
    })

    -- nvim 0.11 native LSP config (must call vim.lsp.config before vim.lsp.enable)
    vim.lsp.config("gopls", {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = { "go.mod", "go.work", ".git" },
    })
    vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", ".git" },
    })
    vim.lsp.config("bashls", {
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh", "bash" },
        root_markers = { ".git" },
    })
    vim.lsp.config("clangd", {
        cmd = { "docker-clangd" },          -- was { "clangd" }
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { "compile_commands.json", ".git" },
    })
    vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".git" },
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
            },
        },
    })

    vim.lsp.enable({ "gopls", "pyright", "lua_ls", "bashls", "clangd" })

    -- :LspReset — native-API replacement for the nvim-lspconfig command.
    -- Stops all LSP clients attached to the current buffer, then re-triggers
    -- attach via :edit so a fresh server (e.g. docker-clangd) starts.
    vim.api.nvim_create_user_command("LspReset", function()
        local bufnr = vim.api.nvim_get_current_buf()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            vim.lsp.stop_client(client.id)
        end
        vim.defer_fn(function()
            -- Re-trigger LSP attach by reloading the buffer. Guard against
            -- no-name buffers (bare :edit errors with E32: No file name).
            if not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end
            if vim.api.nvim_buf_get_name(bufnr) == "" then
                vim.notify("LspReset: buffer has no file; clients stopped, nothing to re-attach",
                    vim.log.levels.WARN)
                return
            end
            vim.api.nvim_buf_call(bufnr, function()
                vim.cmd("edit")
            end)
        end, 500)
    end, { desc = "Reset (restart) LSP client(s) for the current buffer" })

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = on_attach,
    })
end

setmetatable(M, { __call = function(m) m.setup() end })

return M
