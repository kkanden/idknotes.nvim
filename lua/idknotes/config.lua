local M = {}

M.default = {
    -- config of the note window
    win_config = {
        width = math.ceil(vim.o.columns * 0.4),
        height = math.ceil(vim.o.lines * 0.5),
        style = "minimal",
        border = "rounded",
        title_pos = "center",
    },
    fallback_to_cwd = false,
    save_on_close = true,
    keymaps = {
        quit_save = "q", -- `q` in normal mode will save and close the buffer
    },
}

M.user = {}

function M.merge_win_config(win_config, opts)
    local missing_required_config = {
        relative = "editor",
        col = math.floor((vim.o.columns - win_config.width) / 2),
        row = math.floor((vim.o.lines - win_config.height) / 2),
        title = opts.title,
    }
    return vim.tbl_deep_extend("force", win_config, missing_required_config)
end

---@param opts idknotes.Config
function M.validate(opts)
    vim.validate("win_config", opts.win_config, "table")
    vim.validate("fallback_to_cwd", opts.fallback_to_cwd, "boolean")
    vim.validate("save_on_close", opts.save_on_close, "boolean")
    vim.validate("keymaps", opts.keymaps, { "table", "boolean" })
    if opts.keymaps then
        for k, v in pairs(opts.keymaps) do
            vim.validate(string.format("keymaps.%s", k), v, "string")
        end
    end
end

function M.setup_config(opts)
    local config_user = vim.tbl_deep_extend("force", M.default, opts or {})
    M.validate(config_user)
    return config_user
end

return M
