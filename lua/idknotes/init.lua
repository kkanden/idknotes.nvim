local M = {}
local utils = require("idknotes.utils")

local folder_path = vim.fs.joinpath(vim.fn.stdpath("data"), "idknotes")
local global_note_path = vim.fs.joinpath(folder_path, "global.md")
local data_path = vim.fs.joinpath(folder_path, "idknotes.json")

M.data = utils.read_data()

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
        title = opts.title,
        title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, win_config)

    return { buf = buf, win = win }
end

local function create_note(global, name)
    local path = global and global_note_path
        or vim.fs.joinpath(folder_path, name .. ".md")

    vim.fn.writefile({ "" }, path)
end

local function get_project_name()
    local data = utils.read_data()
    local project_path = utils.resolve_project_path()
    return data[project_path]
end

local function add_project_note(name, project_path)
    create_note(false, name)

    M.data = vim.tbl_extend("keep", M.data, { [project_path] = name })
    utils.write_data(M.data)
end

local function create_project_name(project_path)
    vim.ui.input({ prompt = "Enter project name: " }, function(input)
        if not input then return end

        input = input:match("^%s*(.*)%s*$") -- strip whitespace

        if input == "global" then
            vim.notify([[Cannot use name "global".]], vim.log.levels.ERROR)
            return
        end

        -- check if project name is already used
        if vim.tbl_contains(M.data, input) then
            vim.notify("Project name already used.", vim.log.levels.ERROR)
            return
        end

        add_project_note(input, project_path)
    end)
end

function M.toggle_notes(global)
    -- close window
    if vim.api.nvim_win_is_valid(state.floating.win) then
        vim.api.nvim_win_hide(state.floating.win)
        return
    end

    global = global == nil and true

    local project_name
    local project_path
    if not global then
        project_name = get_project_name()
        project_path = utils.resolve_project_path()
    end

    if not project_path and not global then
        vim.notify(
            "Not in a git repository - can't open or create a project note",
            vim.log.levels.WARN
        )
        return
    end

    if not project_name and not global then
        vim.ui.input(
            { prompt = "No note found for current project. Create? [y/n]" },
            function(input)
                if not input or not input:match("y") then return end
                create_project_name(project_path)
            end
        )
        return
    end

    local path = global and global_note_path
        or vim.fs.joinpath(folder_path, get_project_name() .. ".md")

    -- open window
    state.floating = open_floating_window({
        buf = state.floating.buf,
        title = global and " global notes "
            or string.format(" %s project notes ", project_name),
    })
    vim.cmd("edit " .. path)
end

function M.setup(opts)
    opts = opts or {}

    -- setup directory and data json file if they don't exist
    if vim.fn.isdirectory(folder_path) == 0 then vim.fn.mkdir(folder_path) end
    if not utils.readable(data_path) then
        vim.fn.writefile(
            { vim.json.encode({ [global_note_path] = "global.md" }) },
            data_path
        )
    end

    vim.api.nvim_create_user_command("IDKnotes", M.toggle_notes, {})
end

return M
