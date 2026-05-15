---@diagnostic disable: undefined-global

-- ~/.config/nvim/lua/config/functions.lua
local M = {}

M.get_js_formatter = function(bufnr)
    local dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))

    -- 1. Bleeding Edge: Oxc
    if vim.fs.find({ "oxlint.json", ".oxlintrc", ".oxlintrc.json" }, { upward = true, path = dirname })[1] then
        return { "oxc" } -- Note: Ensure conform supports 'oxc', or fallback to 'prettier' if they only use Oxc for linting
    end

    -- 2. Modern Greenfield: Biome
    if vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, path = dirname })[1] then
        return { "biome" }
    end

    -- 3. Mainstream Client: Prettier
    if vim.fs.find({ ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.cjs", "prettier.config.js" }, { upward = true, path = dirname })[1] then
        return { "prettier" }
    end

    -- 4. Legacy Agency: ESLint (--fix)
    if vim.fs.find({ ".eslintrc", ".eslintrc.js", ".eslintrc.json", ".eslintrc.cjs", "eslint.config.js" }, { upward = true, path = dirname })[1] then
        return { "eslint_d" }
    end

    -- 5. Greenfield/Dictator Fallback: Dprint
    return { "dprint" }
end

return M
