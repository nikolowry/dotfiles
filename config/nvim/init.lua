---@diagnostic disable: undefined-global

-- Set leader key to Space BEFORE loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 1. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("config.options")
require("config.autocmds")
local utils = require("config.functions") -- Bring in your DRY helpers

-- 2. Setup Plugins
require("lazy").setup({
    -- lazydev configures lua_ls for your Neovim config, fixing the 'vim' global error
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "Bilal2453/luvit-meta",
        lazy = true, -- optional `vim.uv` typings
    },
    -- ==========================================
    -- 3. THE GUARDRAILS: LSP & Package Management
    -- ==========================================
    {
        "williamboman/mason.nvim",
        lazy = false, -- Force Mason to wake up and inject the PATH
        build = ":MasonUpdate",
        config = function()
            require("mason").setup({
                ui = { border = "rounded" }
            })
        end,
    },
    -- ==========================================
    -- 4. THE ENGINE: Autocompletion (blink.cmp)
    -- ==========================================
    {
        "saghen/blink.cmp",
        lazy = false,  -- We want completion available immediately
        version = "*", -- Lock to stable releases
        build = "cargo build --release",
        opts = {
            -- 'default' for standard mapping, 'super-tab' for VS Code style (Tab to accept)
            keymap = { preset = "super-tab" },

            appearance = {
                -- Sets fallback highlight groups to nvim-cmp's highlight groups
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono"
            },

            -- Default list of sources to use
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            -- Optional: Enable signature help (shows function arguments as you type)
            signature = { enabled = true },

            -- Tell Blink to leave the command line alone so native :E<Tab> works
            -- cmdline = { enabled = false },

            -- Your existing completion options...
            completion = {
                ghost_text = { enabled = false },
                menu = {
                    draw = {
                        -- Notice the 'gap = 1' added to the kind_icon table!
                        columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind", gap = 1 }, { "source_name" } },
                        components = {
                            source_name = {
                                text = function(ctx) return "[" .. ctx.source_name .. "]" end,
                                highlight = "BlinkCmpSource",
                            },
                        },
                    },
                },
            },
        },
    },
    -- ==========================================
    -- 5. NAVIGATION & QoL: Snacks.nvim
    -- ==========================================
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            -- Core UI & Navigation
            picker = { enabled = true, layout = { preset = "ivy" } },
            terminal = { enabled = true },

            -- Quality of Life Additions
            bigfile = { enabled = true },
            indent = {
                enabled = true,
                chunk = { enabled = false },
                scope = { enabed = false },
            },
            notifier = { enabled = true, timeout = 10000 }, -- Beautiful UI popups
            words = { enabled = false },                    -- Auto-highlight matching words under cursor
            statuscolumn = { enabled = true },              -- Clean, non-jittery line number gutter
        },
        keys = {
            -- Picker Keymaps (Bottom Split)
            { "<leader>f",       function() Snacks.picker.files() end,                 desc = "Find Files" },
            { "<leader>fs",      function() Snacks.picker.lsp_workspace_symbols() end, desc = "Find OOP Symbols" },
            { "<leader>sp",      function() Snacks.picker.grep() end,                  desc = "Live Grep" },
            { "<leader><space>", function() Snacks.picker.buffers() end,               desc = "Buffers" },

            -- Utilities
            { "<c-\\>",          function() Snacks.terminal.toggle() end,              desc = "Toggle Terminal" },
            { "<leader>lg",      function() Snacks.lazygit() end,                      desc = "Lazygit" },

            -- Notifier History (See past LSP errors/messages)
            { "<leader>n",       function() Snacks.notifier.show_history() end,        desc = "Notification History" },
            { "<leader>?",       function() Snacks.scratch() end,                      desc = "Toggle Scratchpad" },
        },
    },
    -- ==========================================
    -- 6. THE SHADOW NODE BRIDGE: CodeCompanion
    -- ==========================================
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
            strategies = {
                -- Route all AI actions to your custom local adapter
                chat = { adapter = "openclaw" },
                inline = { adapter = "openclaw" },
                agent = { adapter = "openclaw" },
            },
            adapters = {
                openclaw = function()
                    -- We extend a standard OpenAI-compatible adapter but override the URL
                    return require("codecompanion.adapters").extend("openai_compatible", {
                        env = {
                            -- Strictly requires environment variables. No fallbacks.
                            url = os.getenv("OPENCLAW_URL"),
                            api_key = os.getenv("OPENCLAW_TOKEN")
                        },
                        schema = {
                            model = {
                                -- Defining your local S-Tier model
                                default = "qwen3-coder-next:latest",
                            },
                        },
                    })
                end,
            },
            display = {
                -- Keep the chat in a clean vertical split, acting like a true sidebar assistant
                chat = { window = { layout = "vertical", width = 0.3 } },
            },
        },
        keys = {
            { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle OpenClaw AI Chat" },
            { "<leader>ca", "<cmd>CodeCompanionActions<cr>",     desc = "OpenClaw AI Actions" },
        },
    },
    -- ==========================================
    -- 7. VISUALS & UI
    -- ==========================================
    {
        "nvim-tree/nvim-web-devicons",
        -- This turns off all the crazy colors. Pure, cohesive, monochrome utility.
        opts = { color_icons = false },
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "base16",
                -- This explicitly kills the arrow separators
                component_separators = '',
                section_separators = '',
            },
            sections = {
                lualine_c = {
                    { 'filename' },
                    {
                        'buffers',
                        mode = 4, -- mode 4 forces it to display "bufnr: filename"
                        buffers_color = {
                            active = { fg = "#ffffff", bg = "#585858", gui = "bold" },
                            inactive = { fg = "#b8b8b8", bg = "NONE" },
                        },
                        symbols = { modified = ' ●', alternate_file = '', directory = '' },
                    }
                }
            },
        },
    },
    {
        "lewis6991/gitsigns.nvim", -- Replaces vim-gitgutter
        opts = {
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
        },
    },
    {
        "brenoprata10/nvim-highlight-colors", -- Replaces lilydjwg/colorizer

        -- Changing "virtual" to "background" completely kills the icon chip
        opts = { render = "background", enable_named_colors = true, enable_tailwind = true },
    },
    {
        "RRethy/nvim-base16", -- Replaces base16-vim
        config = function()
            -- Automatically load your system's base16 theme if you still use it globally
            vim.cmd("colorscheme base16-default-dark")
        end,
    },
    -- ==========================================
    -- LSP UI: Lspsaga (Stripped down to Hover Only)
    -- ==========================================
    {
        "nvimdev/lspsaga.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lspsaga").setup({
                ui = { border = "rounded" },
                lightbulb = { enable = false },
            })
        end,
        keys = {
            -- ONLY Hover Documentation is handled by Lspsaga now
            { "K", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Documentation" },
        },
    },
    -- ==========================================
    -- DIAGNOSTICS DASHBOARD: Trouble
    -- ==========================================
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        opts = {
            icons = { indent = { top = "│ ", middle = "├╴", last = "└╴" } },
            modes = {
                diagnostics = {
                    auto_close = true, -- Auto-close when the last error is fixed
                },
            }
        },
        keys = {
            { "<leader>e", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document Diagnostics" },
            { "<leader>x", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
            { "gr", "<cmd>Trouble lsp_references toggle<cr>", desc = "LSP References (Trouble)" },
        },
    },
    -- ==========================================
    -- 8. FORMATTING & LINTING (The Clear Separation)
    -- ==========================================
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = {
                -- Point all JS/TS ecosystem files to your DRY traffic cop
                javascript = utils.get_js_formatter,
                typescript = utils.get_js_formatter,
                javascriptreact = utils.get_js_formatter,
                typescriptreact = utils.get_js_formatter,
                php = utils.get_php_formatter,
                json = { "dprint" },
                markdown = { "dprint" },
                css = { "dprint" },
                scss = { "dprint" },
                html = { "dprint" },
                vue = { "dprint" },
                graphql = { "dprint" },
                yaml = { "dprint" },
                sql = { "sqlfluff" },
                sh = { "shfmt" },
            },
            -- NEW: Inject the -i 4 flag into shfmt globally
            formatters = {
                shfmt = {
                    prepend_args = { "-i", "4" },
                },
                php_cs_fixer = {
                    prepend_args = function(self, ctx)
                        local dirname = vim.fs.dirname(ctx.filename)
                        local project_cfg = vim.fs.find(
                            { ".php-cs-fixer.dist.php", ".php-cs-fixer.php" },
                            { upward = true, path = dirname }
                        )[1]
                        if project_cfg then
                            return {}
                        end
                        return { "--config=" .. vim.fn.expand("~/.config/php-cs-fixer/config.php") }
                    end,
                },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        },
        keys = {
            { "<leader>F", function() require("conform").format() end, desc = "Format Buffer" },
        },
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost", "InsertLeave" },
        config = function()
            -- ESLint exists strictly as a diagnostic reader
            require('lint').linters_by_ft = {
                javascript = { "eslint" },
                typescript = { "eslint" },
                sh = { "shellcheck" }
            }

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                callback = function(args)
                    local lint = require("lint")
                    local filetype = vim.bo[args.buf].filetype

                    -- If it's a style file, dynamically check for stylelint
                    if filetype == "css" or filetype == "scss" then
                        local linter = utils.get_style_linter(args.buf)
                        if linter then
                            lint.try_lint(linter)
                        end
                    elseif filetype == "php" then
                        local linter = utils.get_php_linter(args.buf)
                        if linter then
                            lint.try_lint(linter)
                        end
                    else
                        -- Run default linters for everything else
                        lint.try_lint()
                    end
                end,
            })
        end,
    },
    -- ==========================================
    -- 9. LEGACY SYNTAX FALLBACKS
    -- ==========================================
    {
        "lumiliet/vim-twig",
        ft = { "twig", "html.twig" } -- Strictly lazy-load ONLY when opening a Twig file
    },
-- ==========================================
    -- QUALITY OF LIFE & WORKFLOW
    -- ==========================================

    -- 1. Auto-closing brackets and quotes
    {
        "echasnovski/mini.pairs",
        event = "InsertEnter",
        opts = {
            modes = { insert = true, command = false, terminal = false },
        },
    },

    -- 2. Add/Delete/Change surrounding pairs (quotes, tags, brackets)
    -- Usage: 'sa' (add), 'sd' (delete), 'sr' (replace)
    {
        "echasnovski/mini.surround",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            mappings = {
                add = "sa",            -- Add surrounding in Normal and Visual modes
                delete = "sd",         -- Delete surrounding
                replace = "sr",        -- Replace surrounding
                find = "sf",           -- Find surrounding (to the right)
                find_left = "sF",      -- Find surrounding (to the left)
                highlight = "sh",      -- Highlight surrounding
                update_n_lines = "sn", -- Update `n_lines`
            },
        },
    },

    -- 3. Context-Aware Commenting (Crucial for React/JSX/Vue)
    -- Neovim natively supports 'gc' to comment, but it gets confused in embedded languages.
    -- This plugin seamlessly updates Neovim's native commentstring based on cursor location.
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            enable_autocmd = false,
        },
        config = function(_, opts)
            require("ts_context_commentstring").setup(opts)
            -- Hijack Neovim's native commenting API to use this plugin's logic
            local get_option = vim.filetype.get_option
            vim.filetype.get_option = function(filetype, option)
                return option == "commentstring"
                    and require("ts_context_commentstring.internal").calculate_commentstring()
                    or get_option(filetype, option)
            end
        end,
    },
}, {
    -- This second table is the Lazy configuration
    ui = { border = "rounded" }
})

-- ==========================================
-- NATIVE NEOVIM 0.12 LSP STARTUP
-- ==========================================
local servers = {
    "phpactor", "lua_ls", "jsonls", "clangd", "dockerls",
    "gopls", "graphql", "pylsp", "eslint", "ts_ls", "vimls", "yamlls"
}

for _, server in ipairs(servers) do
    if server == "eslint" then
        vim.lsp.config("eslint", {
            settings = {
                -- Force ESLint to use your global Node modules
                nodePath = "/usr/lib/node_modules"
            }
        })
    end

    vim.lsp.enable(server)
end

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    underline = false,
})
