return {
    -- Mason: auto-install LSP servers
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "pyright",
                "omnisharp",
                "jsonls",
                "yamlls",
                "dockerls",
                "bashls",
            },
            automatic_installation = true,
        },
    },

    -- LSP server definitions (registers configs for vim.lsp.config)
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Keymaps on LSP attach
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true }),
                callback = function(event)
                    local buf = event.buf
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
                    end

                    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
                    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
                    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
                    map("n", "gr", vim.lsp.buf.references, "References")
                    map("n", "K", vim.lsp.buf.hover, "Hover documentation")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
                    map("n", "<leader>fs", vim.lsp.buf.document_symbol, "Document symbols")
                    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
                    map("n", "<leader>f", function()
                        vim.lsp.buf.format({ async = true })
                    end, "Format buffer")
                end,
            })

            -- Diagnostic display
            vim.diagnostic.config({
                virtual_text = { prefix = "●" },
                signs = true,
                underline = true,
                update_in_insert = false,
                float = { border = "rounded", source = true },
            })

            -- Server configs via vim.lsp.config (Neovim 0.11+)
            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = { checkThirdParty = false },
                            telemetry = { enable = false },
                            diagnostics = { globals = { "vim" } },
                        },
                    },
                },
                ts_ls = {},
                pyright = {},
                omnisharp = {},
                jsonls = {},
                yamlls = {},
                dockerls = {},
                bashls = {},
            }

            for server, config in pairs(servers) do
                config.capabilities = capabilities
                vim.lsp.config(server, config)
            end

            vim.lsp.enable(vim.tbl_keys(servers))
        end,
    },
}
