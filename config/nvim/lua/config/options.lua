---@diagnostic disable: undefined-global

local opt = vim.opt

-- Code Formatting (Your personal defaults)
opt.wrap = false
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.number = true
opt.splitbelow = true
opt.splitright = true
opt.ignorecase = true
opt.smartcase = true
opt.showmatch = true
opt.colorcolumn = "80"

-- Netrw tweaks
vim.g.netrw_banner = 0
vim.g.netrw_altv = 1
vim.g.netrw_preview = 1
vim.g.netrw_special_syntax = 1
vim.g.netrw_sort_sequence =
[[^\.\.\=[\/]$,@,[\/]$,\<core\%(\.\d\+\)\=\>$,\~\=\*$,*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\~$]]
vim.g.netrw_localcopydircmd = 'cp -r'
vim.g.netrw_localrmdir = ''

-- Keep visual selection when indenting (Multiline Tabbing fix)
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- System clipboard
-- Re-map Ctrl-C in visual mode to yank to the system clipboard
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to System Clipboard" })

-- Undo / Redo Mappings
vim.keymap.set("n", "<C-z>", "<cmd>undo<CR>", { desc = "Undo" })
vim.keymap.set("n", "<C-y>", "<cmd>redo<CR>", { desc = "Redo" })

-- Insert Mode Undo / Redo (Escapes insert mode automatically)
vim.keymap.set("i", "<C-z>", "<Esc><cmd>undo<CR>", { desc = "Undo" })
vim.keymap.set("i", "<C-y>", "<Esc><cmd>redo<CR>", { desc = "Redo" })

-- Alias :E to natively trigger :Explore
vim.api.nvim_create_user_command("E", "Explore", {})

-- Disable all LSP Inlay Hints (No fake parameter names injected into code)
vim.lsp.inlay_hint.enable(false)

-- Hide the '~' at the end of the buffer
vim.opt.fillchars:append({ eob = " " })
