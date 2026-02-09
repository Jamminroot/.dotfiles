return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            ensure_installed = {
                "bash", "c", "c_sharp", "cmake", "cpp", "css", "diff",
                "dockerfile", "gitignore", "go", "html", "javascript",
                "json", "lua", "luadoc", "markdown", "markdown_inline",
                "python", "query", "regex", "rust", "toml", "tsx",
                "typescript", "vim", "vimdoc", "xml", "yaml",
            },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        },
        main = "nvim-treesitter",
    },
}
