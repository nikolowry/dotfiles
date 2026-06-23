---@diagnostic disable: undefined-global

-- ~/.config/nvim/lua/config/functions.lua
local M = {}

-- Local helper function to DRY up the config searching
local function has_config(filenames, dirname)
    -- vim.fs.find returns a table of found paths.
    -- In Lua, [1] gets the first item. If it exists, it returns true.
    return vim.fs.find(filenames, { upward = true, path = dirname })[1] ~= nil
end

local function project_owns_phpcs(dirname)
    return has_config({ "phpcs.xml", "phpcs.xml.dist", ".phpcs.xml", ".phpcs.xml.dist" }, dirname)
        or has_config({ "vendor/bin/phpcs" }, dirname)
end

local function project_owns_php_cs_fixer(dirname)
    return has_config({ ".php-cs-fixer.dist.php", ".php-cs-fixer.php" }, dirname)
        or has_config({ "vendor/bin/php-cs-fixer" }, dirname)
end

M.get_php_formatter = function(bufnr)
    local dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    if project_owns_phpcs(dirname) then
        return { "phpcbf" }
    end
    return { "php_cs_fixer" }  -- covers both project-owned and global default
end

M.get_php_linter = function(bufnr)
    local dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    if project_owns_phpcs(dirname) then
        return { "phpcs" }
    end
    if has_config({ "phpstan.neon", "phpstan.neon.dist", "phpstan.dist.neon" }, dirname) then
        return { "phpstan" }
    end
    return nil  -- no linter when no project signal
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
