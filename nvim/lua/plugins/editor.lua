return {
    -- Auto-close brackets/quotes
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local autopairs = require("nvim-autopairs")
            autopairs.setup({ check_ts = true })

            -- Integrate with cmp
            local cmp_ok, cmp = pcall(require, "cmp")
            if cmp_ok then
                local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end
        end,
    },

    -- Comment toggle
    {
        "numToStr/Comment.nvim",
        keys = {
            { "gcc", mode = "n", desc = "Toggle comment" },
            { "gc", mode = { "n", "v" }, desc = "Comment" },
        },
        opts = {},
    },

    -- Surround (ys, ds, cs)
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },

    -- Better text objects
    {
        "echasnovski/mini.ai",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },

    -- Highlight TODO/FIXME/etc
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = "nvim-lua/plenary.nvim",
        opts = {},
        keys = {
            { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" },
        },
    },

    -- Better terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        keys = {
            { "<C-\\>", desc = "Toggle terminal" },
            { "<leader>tg", desc = "Lazygit" },
        },
        opts = {
            open_mapping = [[<C-\>]],
            direction = "float",
            float_opts = { border = "curved" },
        },
        config = function(_, opts)
            require("toggleterm").setup(opts)

            local Terminal = require("toggleterm.terminal").Terminal
            local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })
            vim.keymap.set("n", "<leader>tg", function() lazygit:toggle() end, { desc = "Lazygit" })
        end,
    },
}
