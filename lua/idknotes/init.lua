local M = {}
local cache = {}

local utils = require("idknotes.utils")

local folder_path = vim.fs.joinpath(vim.fn.stdpath("data"), "idknotes")
local global_note_path = vim.fs.joinpath(folder_path, "global.md")
local data_path = vim.fs.joinpath(folder_path, "idknotes.json")
local global_name = "_GLOBAL_"

-- set up cache
cache.data = utils.readable(data_path) and utils.read_data() or nil
cache.project_path = utils.resolve_project_path()
cache.project_name = utils.get_project_name(cache.data, cache.project_path)

local state = {
    floating = {
        buf = -1,
        win = -1,
    },
}
local function open_floating_window(opts)
    opts = opts or {}
    local width = math.ceil(vim.o.columns * 0.4)
    local height = math.ceil(vim.o.lines * 0.5)

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

local function add_project_note(name, project_path)
    create_note(false, name)

    cache.data = vim.tbl_extend("keep", cache.data, { [project_path] = name })
    utils.write_data(cache.data)

    vim.notify(
        ([[Successfully created a project note "%s".]]):format(name),
        vim.log.levels.INFO
    )
end

local function process_project_name(project_name)
    if not project_name then return end

    project_name = project_name:match("^%s*(.*)%s*$") -- strip whitespace

    if project_name == global_name then
        vim.notify(
            ([[Cannot use name "global".]]):format(global_name),
            vim.log.levels.ERROR
        )
        return
    end

    -- check if project name is already used
    if vim.tbl_contains(cache.data, project_name) then
        vim.notify("Project name already used.", vim.log.levels.ERROR)
        return
    end

    cache.project_name = project_name

    return project_name
end

local function create_project_name(project_path)
    vim.ui.input({ prompt = "Enter project name: " }, function(input)
        input = process_project_name(input)
        if not input then return end

        add_project_note(cache.project_name, project_path)
    end)
end

local function change_project_name(project_path)
    if cache.data[project_path] == nil then
        vim.notify("No project note created yet.", vim.log.levels.WARN)
        return
    end

    vim.ui.input({ prompt = "Enter new project name: " }, function(input)
        input = process_project_name(input)
        if not input then return end

        cache.data[project_path] = input
        utils.write_data(cache.data)

        vim.notify(
            ([[Successfully changed project name to "%s".]]):format(input),
            vim.log.levels.INFO
        )
    end)
end

local function delete_note(project_name)
    local project_path = utils.project_path_from_name(project_name, cache.data)
    cache.data[project_path] = nil
    utils.write_data(cache.data)

    vim.notify(
        ([[Successfully deleted project note "%s"]]):format(project_name)
    )
end

local function manage_notes(project_path)
    local choices = vim.tbl_filter(
        function(value) return value ~= global_name end,
        cache.data
    )

    if #choices == 0 then
        vim.notify("No project notes to manage.", vim.log.levels.WARN)
        return
    end

    vim.ui.select(
        choices,
        { prompt = "Select project note to manage" },
        function(item)
            if not item then return end
            vim.ui.select(
                { "delete", "change name" },
                { prompt = "What would you like to do?" },
                function(choice)
                    if not choice then return end
                    if choice == "delete" then
                        delete_note(item)
                    elseif choice == "change name" then
                        change_project_name(project_path)
                    end
                end
            )
        end
    )
end

function M.toggle_notes(global)
    -- close window
    if vim.api.nvim_win_is_valid(state.floating.win) then
        vim.api.nvim_win_hide(state.floating.win)
        return
    end

    global = global == nil and true

    if not cache.project_path and not global then
        vim.notify(
            "Not in a git repository - can't open or create a project note.",
            vim.log.levels.WARN
        )
        return
    end

    if not cache.project_name and not global then
        vim.ui.input(
            { prompt = "No note found for current project. Create? [y/n]" },
            function(input)
                if not input or not input:match("y") then return end
                create_project_name(cache.project_path)
            end
        )
        return
    end

    local path = global and global_note_path
        or vim.fs.joinpath(folder_path, cache.project_name .. ".md")

    -- open window
    state.floating = open_floating_window({
        buf = state.floating.buf,
        title = global and " global notes "
            or string.format(" %s project notes ", cache.project_name),
    })
    vim.cmd("edit " .. path)
end

function M.setup(opts)
    opts = opts or {}

    -- setup directory and data json file if they don't exist yet
    if vim.fn.isdirectory(folder_path) == 0 then vim.fn.mkdir(folder_path) end
    if not utils.readable(data_path) then
        vim.fn.writefile(
            { vim.json.encode({ [global_name] = global_name }) },
            data_path
        )
        cache.data = utils.read_data()
    end

    vim.api.nvim_create_user_command("IDKnotes", M.toggle_notes, {})
    vim.api.nvim_create_user_command(
        "IDKnotesChange",
        function() change_project_name(cache.project_path) end,
        {}
    )
    vim.api.nvim_create_user_command(
        "IDKnotesManage",
        function() manage_notes(cache.project_path) end,
        {}
    )
end

return M
