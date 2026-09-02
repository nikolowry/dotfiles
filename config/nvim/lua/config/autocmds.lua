---@diagnostic disable: undefined-global

-- Automatically create parent directories if they don't exist when saving
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        local dir = vim.fn.fnamemodify(args.file, ":p:h")
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end
    end,
})

-- Trim trailing whitespace on save (except markdown)
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        if vim.bo[args.buf].filetype ~= "markdown" then
            local save_cursor = vim.fn.getpos(".")
            vim.cmd([[%s/\s\+$//e]])
            vim.fn.setpos(".", save_cursor)
        end
    end,
})

-- Override colorscheme highlights (Transparency, LineNr, WinSeparator)
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        -- Restore transparent background for active AND inactive windows
        vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE", ctermbg = "NONE" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE", ctermbg = "NONE" })

        -- Your Misc GUI tweaks
        vim.api.nvim_set_hl(0, "NonText", { ctermfg = 0 })
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#585858", bg = "NONE" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#d8d8d8", bg = "NONE" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#282828" })

        -- Make floating windows, modals, and their borders transparent
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", ctermbg = "NONE" })
        vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE", ctermbg = "NONE" })

        -- NEW: Mute the active indent line to match the inactive ones
        vim.api.nvim_set_hl(0, "SnacksIndent", { link = "Comment" })
        vim.api.nvim_set_hl(0, "SnacksIndentScope", { link = "Comment" })

        -- Bulletproof GitGutter Transparency (Preserving Base16 Colors)
        vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#a1b56c", bg = "NONE" })
        vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#7cafc2", bg = "NONE" })
        vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = "#ba8baf", bg = "NONE" })
        vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#ab4642", bg = "NONE" })

        -- Bulletproof Squiggly Line Kills
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = false, underline = false })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = false, underline = false })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = false, underline = false })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = false, underline = false })

        -- ==========================================
        -- Restore Legacy HTML/XML Tag Colors (Base16 Blue)
        -- ==========================================
        vim.api.nvim_set_hl(0, "Tag", { fg = "#d8d8d8" })
        vim.api.nvim_set_hl(0, "xmlTag", { fg = "#d8d8d8" })
        vim.api.nvim_set_hl(0, "xmlTagName", { fg = "#d8d8d8" })
        vim.api.nvim_set_hl(0, "xmlEndTag", { fg = "#d8d8d8" })

        -- And covering standard HTML just in case:
        vim.api.nvim_set_hl(0, "htmlTag", { fg = "#d8d8d8" })
        vim.api.nvim_set_hl(0, "htmlEndTag", { fg = "#d8d8d8" })
    end,
})

-- Asynchronously mute diagnostics for any file ignored by Git (vendor, contrib, node_modules)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local filepath = vim.api.nvim_buf_get_name(args.buf)
        if filepath == "" then return end

        -- Run 'git check-ignore' in a background thread
        vim.system({ 'git', 'check-ignore', '-q', filepath }, {}, function(obj)
            -- Exit code 0 means Git is explicitly ignoring this file
            if obj.code == 0 then
                -- Safely schedule the diagnostic toggle back on the main UI thread
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(args.buf) then
                        vim.diagnostic.enable(false, { bufnr = args.buf })
                    end
                end)
            end
        end)
    end,
})

-- Map native LSP and Diagnostic functions when a Language Server attaches
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local opts = { buffer = args.buf, silent = true }

        -- Instant Definition Jump (Native)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

        -- Native Neovim Rename (Prompts at the bottom command line)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        -- Native Code Actions
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        -- Diagnostic Jumping (Restoring your muscle memory)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    end,
})

-- ==========================================
-- BULLETPROOF BIG FILE PAGER
-- ==========================================
vim.api.nvim_create_autocmd("BufReadPre", {
    pattern = "*",
    callback = function(args)
        local file_name = vim.api.nvim_buf_get_name(args.buf)
        local ok, stat = pcall(vim.uv.fs_stat, file_name)

        -- If file is larger than 2MB (2048 * 1024 bytes)
        if ok and stat and stat.size > 2097152 then
            -- Disable UI bottlenecks
            vim.opt_local.wrap = false
            vim.opt_local.list = false
            vim.opt_local.cursorline = false
            vim.opt_local.cursorcolumn = false
            vim.opt_local.foldenable = false
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.spell = false

            -- Disable file I/O locks
            vim.opt_local.swapfile = false
            vim.opt_local.undofile = false

            -- Nuke all regex syntax highlighting
            vim.cmd("syntax clear")
            vim.cmd("syntax off")
            vim.cmd("filetype indent off")

            -- Kill the bracket matching search
            vim.cmd("if exists(':NoMatchParen') | NoMatchParen | endif")
        end
    end,
})

-- Drupal Filetypes
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.module", "*.install", "*.test", "*.inc", "*.profile", "*.view", "*.theme" },
    callback = function()
        vim.bo.filetype = "php"
    end,
})

-- Modern Neovim Filetype Detection
vim.filetype.add({
    extension = {
        twig = "twig",
    },
    pattern = {
        [".*%.html%.twig"] = "twig",
    },
})

-- Neovim creates an empty unnamed buffer at startup. When you launch on a
-- directory, the explorer opens in a new buffer and the empty one is left
-- in the buffer list, where it collects stray yanks and paste targets.
-- Delete it once anything real is loaded.
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("kill_empty_noname", { clear = true }),
    callback = function()
        local current = vim.api.nvim_get_current_buf()

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local is_empty_scratch = vim.api.nvim_buf_is_loaded(buf)
                and buf ~= current
                and vim.api.nvim_buf_get_name(buf) == ""
                and vim.bo[buf].buftype == ""
                and vim.bo[buf].modified == false
                and vim.api.nvim_buf_line_count(buf) == 1
                and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""

            if is_empty_scratch then
                pcall(vim.api.nvim_buf_delete, buf, {})
            end
        end
    end,
})
