local languages = {
    "bash", "c", "c_sharp", "cmake", "cpp", "css", "diff",
    "dockerfile", "gitignore", "go", "html", "javascript",
    "json", "lua", "luadoc", "markdown", "markdown_inline",
    "python", "query", "regex", "rust", "toml", "tsx",
    "typescript", "vim", "vimdoc", "xml", "yaml",
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({})
            require("nvim-treesitter").install(languages)

            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })
        end,
    },
}
