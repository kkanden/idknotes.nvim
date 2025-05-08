local M = {}
local utils = require("idknotes.utils")

local folder_path = vim.fs.joinpath(vim.fn.stdpath("data"), "idknotes")
local global_note_path = vim.fs.joinpath(folder_path, "global.md")
local data_path = vim.fs.joinpath(folder_path, "idknotes.json")

local state = {
    floating = {
        buf = -1,
        win = -1,
    },
}
local function open_floating_window(opts)
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

local function create_note(path) vim.fn.writefile({ "" }, path) end

local function read_data()
    local lines = vim.fn.readfile(data_path)
    return vim.json.decode(lines)
end

local function write_data(data)
    local json = vim.json.encode(data)
    vim.fn.writefile({ json }, data_path)
end

local function get_project_name()
    vim.ui.input({ prompt = "Enter project name: " }, function(input)
        if not input then return end
        local data = read_data()

        -- check if project name is already used
        for key, _ in pairs(data) do
            if input == key then
                vim.notify("Project name already used.", vim.log.levels.ERROR)
                return
            end
        end

        local working_dir = vim.cmd("pwd")
        local root_dir = vim.fs.root(pwd, ".git") -- per-project notes will work on git repositories
        if not root_dir then
            vim.notify(
                "Not in a git repository. Can't create a project note.",
                vim.log.levels.ERROR
            )
            return
        end

        data = vim.tbl_extend("keep", data, { [input] = root_dir })
        write_data(data)
    end)
end

function M.toggle_notes(global)
    global = global or true
    local path = global and global_note_path
    if vim.api.nvim_win_is_valid(state.floating.win) then
        -- close window
        vim.api.nvim_win_hide(state.floating.win)
    else
        -- open window
        if not utils.readable(path) then create_note(path) end
        state.floating =
            open_floating_window({ buf = state.floating.buf, global = global })
        vim.cmd("edit " .. path)
    end
end

function M.setup(opts)
    opts = opts or {}

    -- setup directory and data json file if they don't exist
    if vim.fn.isdirectory(folder_path) == 0 then vim.fn.mkdir(folder_path) end
    if not utils.readable(data_path) then
        vim.fn.writefile(vim.json.encode({ global = "GLOBAL" }), data_path)
    end

    vim.api.nvim_create_user_command("IDKnotes", M.toggle_notes, {})
end

return M
