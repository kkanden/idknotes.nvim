-- based on https://github.com/nvim-neorocks/nvim-best-practices?tab=readme-ov-file#speaking_head-user-commands
local M = {}

---@class SubCommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments

---@param subcommands_tbl table<string, SubCommand>
---@param opts table :h lua-guide-commands-create
local function cmd(subcommands_tbl, opts)
    local fargs = opts.fargs
    if #fargs == 0 then
        subcommands_tbl._DEFAULT_.impl({}, opts)
        return
    end
    local subcommand_key = fargs[1]
    -- Get the subcommand's arguments, if any
    local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
    local subcommand = subcommands_tbl[subcommand_key]
    if not subcommand then
        vim.notify(
            "IDKnotes: Unknown command: " .. subcommand_key,
            vim.log.levels.ERROR
        )
        return
    end
    -- Invoke the subcommand
    subcommand.impl(args, opts)
end

function M.setup_usercmd(subcommands_tbl)
    -- NOTE: the options will vary, based on your use case.
    vim.api.nvim_create_user_command(
        "IDKnotes",
        function(opts) cmd(subcommands_tbl, opts) end,
        {
            nargs = "*",
            bang = true,
            complete = function(arg_lead, cmdline, _)
                -- Get the subcommand.
                local subcmd_key, subcmd_arg_lead =
                    cmdline:match("^['<,'>]*IDKnotes[!]*%s(%S+)%s(.*)$")
                if
                    subcmd_key
                    and subcmd_arg_lead
                    and subcommands_tbl[subcmd_key]
                    and subcommands_tbl[subcmd_key].complete
                then
                    -- The subcommand has completions. Return them.
                    return subcommands_tbl[subcmd_key].complete(subcmd_arg_lead)
                end
                -- Check if cmdline is a subcommand
                if cmdline:match("^['<,'>]*IDKnotes[!]*%s+%w*$") then
                    -- Filter subcommands that match
                    local subcommand_keys = vim
                        .iter(vim.tbl_keys(subcommands_tbl))
                        :filter(function(x) return x ~= "_DEFAULT_" end) -- remove _DEFAULT_
                        :totable()
                    return vim.iter(subcommand_keys)
                        :filter(
                            function(key) return key:find(arg_lead) ~= nil end
                        )
                        :totable()
                end
            end,
        }
    )
end
return M
