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

local function on_attach(args)
    local bufnr = args.buf
    local map = function(keys, func)
        vim.keymap.set("n", keys, func, { buffer = bufnr })
    end
    map("gd", vim.lsp.buf.definition)
    map("gr", vim.lsp.buf.references)
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
    vim.lsp.config("gopls", {})
    vim.lsp.config("pyright", {})
    vim.lsp.config("bashls", {})
    vim.lsp.config("clangd", {})
    vim.lsp.config("lua_ls", {
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
            },
        },
    })

    vim.lsp.enable({ "gopls", "pyright", "lua_ls", "bashls", "clangd" })

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = on_attach,
    })
end

setmetatable(M, { __call = function(m) m.setup() end })

return M
