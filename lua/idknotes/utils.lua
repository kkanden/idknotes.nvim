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

---Returns all project paths associated with note `project_name`.
---@param project_name string
---@param data table
---@return table
function M.project_path_from_name(project_name, data)
    local project_paths = {}
    for k, v in pairs(data) do
        if v == project_name then table.insert(project_paths, k) end
    end
    return project_paths
end

function M.isinteger(x) return math.ceil(x) == x end

---Returns a list-like table containing unique values from table `t`.
---@param t table
---@return table
function M.unique(t)
    local found = {}
    local ret = {}
    for _, v in pairs(t) do
        if not vim.tbl_contains(found, v) then
            table.insert(found, v)
            table.insert(ret, v)
        end
    end
    return ret
end

return M
