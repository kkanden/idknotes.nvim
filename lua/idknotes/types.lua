---@class idknotes.Config
---@field win_config? vim.api.keyset.win_config options of the notes window
---@field fallback_to_cwd? boolean whether to fallback to cwd if not in a git repohe
---@field save_on_close? boolean
---@field keymaps? table<string, string> | boolean addtional buffer keymaps, set to false to disable

---@class idknotes.OpenWinOpts
---@field buf integer
---@field win? integer
---@field title string
