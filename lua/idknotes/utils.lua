local M = {}

local folder_path = vim.fs.joinpath(vim.fn.stdpath("data"), "idknotes")
local data_path = vim.fs.joinpath(folder_path, "idknotes.json")

function M.readable(file) return vim.fn.filereadable(file) == 1 end

function M.read_data()
    local lines = vim.fn.readfile(data_path)
    lines = table.concat(lines) -- vim.json.decode needs a pure string
    return vim.json.decode(lines)
end

function M.write_data(data)
    local json = vim.json.encode(data)
    vim.fn.writefile({ json }, data_path)
end

function M.resolve_project_path()
    local working_dir = vim.fn.getcwd()
    return vim.fs.root(working_dir, ".git") -- per-project notes will work on git repositories
end

function M.get_project_name(data, project_path)
    return data and data[project_path] or nil
end

function M.project_path_from_name(project_name, data)
    local project_path
    for k, v in pairs(data) do
        if v == project_name then project_path = k end
    end
    return project_path
end

return M
