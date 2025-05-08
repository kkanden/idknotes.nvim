local M = {}

function M.readable(file) return vim.fn.filereadable(file) == 1 end

return M
