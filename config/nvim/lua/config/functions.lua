---@diagnostic disable: undefined-global

-- ~/.config/nvim/lua/config/functions.lua
local M = {}

-- Local helper function to DRY up the config searching
local function has_config(filenames, dirname)
    -- vim.fs.find returns a table of found paths.
    -- In Lua, [1] gets the first item. If it exists, it returns true.
    return vim.fs.find(filenames, { upward = true, path = dirname })[1] ~= nil
end

M.get_js_formatter = function(bufnr)
    local dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))

    -- 1. Bleeding Edge: Oxc
    if has_config({ "oxlint.json", ".oxlintrc", ".oxlintrc.json" }, dirname) then
        return { "oxc" }
    end

    -- 2. Modern Greenfield: Biome
    if has_config({ "biome.json", "biome.jsonc" }, dirname) then
        return { "biome" }
    end

    -- 3. Mainstream Client: Prettier
    if has_config({ ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.cjs", "prettier.config.js" }, dirname) then
        return { "prettier" }
    end

    -- 4. Legacy Agency: ESLint (--fix)
    if has_config({ ".eslintrc", ".eslintrc.js", ".eslintrc.json", ".eslintrc.cjs", "eslint.config.js" }, dirname) then
        return { "eslint_d" }
    end

    -- 5. Greenfield/Dictator Fallback: Dprint
    return { "dprint" }
end

M.get_style_linter = function(bufnr)
    local dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))

    local stylelint_configs = {
        ".stylelintrc",
        ".stylelintrc.json",
        ".stylelintrc.yaml",
        ".stylelintrc.yml",
        ".stylelintrc.js",
        "stylelint.config.js",
        "stylelint.config.cjs"
    }

    if has_config(stylelint_configs, dirname) then
        return { "stylelint" }
    end

    -- Return nil (Lua's null) to indicate no linter should run
    return nil
end

return M
