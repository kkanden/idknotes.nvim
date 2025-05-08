local M = {}

local path = vim.fs.joinpath(vim.fn.stdpath("data"), "idknotes/global.md")

local state = {
    floating = {
        buf = -1,
        win = -1,
    },
}
local function create_floating_windows(opts)
    opts = opts or {}
    local width = math.ceil(vim.o.columns * 0.5)
    local height = math.ceil(vim.o.lines * 0.3)

    -- center
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    local buf
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, false)
    end

    local win_config = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
        title = " idk notes ",
        title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, win_config)

    return { buf = buf, win = win }
end

local function notes_readable(global)
    global = global or true
    return vim.fn.filereadable(path) == 1
end

local function create_notes(global)
    global = global or true
    vim.fn.writefile("", path)
end

local function toggle_notes(global)
    global = global or true
    if vim.api.nvim_buf_is_valid(state.floating.win) then
        -- close window
        vim.api.nvim_win_hide(state.floating.win)
        vim.api.nvim_feedkeys("<C-c>", "n", false) -- exit input mode on exit
    else
        -- open window
        if not notes_readable(global) then create_notes(global) end
        state.floating = create_floating_windows({ buf = state.floating.buf })
        vim.cmd("edit " .. path)
    end
end

function M.setup(opts)
    opts = opts or {}
    vim.api.nvim_create_user_command("IDKnotes", toggle_notes, {})
    vim.keymap.set("n", "n\\", toggle_notes)
end

return M
