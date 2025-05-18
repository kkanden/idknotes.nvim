IDKnotes (notice the silent "k") because idk what i'm doing wasting my time on
something that has probably been implemented dozens of times already in a better
way.

## Usage

The plugin is based upon a single user command `:IDKnotes` which takes optional
arguments. If no argument is provided, the global notes are opened; with a bang
(`:IDKnotes!`), the project notes are opened (see below).

Upon trying to open a project note in a project for which a project note has not
yet been created, you will be prompted to provide a name associated with the
project. You can change the name afterward using <nobr>`:IDKnotes rename`</nobr>
or <nobr>`:IDKnotes manage`</nobr> (from where you can also delete the note).

## Configuration

Example configuration using `lazy.nvim`:

```lua
return {
    "kkanden/idknotes.nvim",
    ---@type idknotes.Config
    opts = {},
    config = function(_, opts)
        require("idknotes").setup(opts) -- setup is required for the plugin to work

        vim.keymap.set("n", "<leader>n", "<Cmd>IDKnotes<CR>") -- global notes

        vim.keymap.set("n", "<leader>m", "<Cmd>IDKnotes!<CR>") -- project notes
    end,
}
```

<details>
<summary>Default options</summary>

```lua
{
    -- config of the note window
    win_config = {
        width = 0.4, -- if between 0 and 1 taken as fraction of the window, if integer taken as number or lines
        height = 0.5, -- same as above
        style = "minimal",
        border = "rounded",
        title_pos = "center",
    },
    fallback_to_cwd = false, -- if not in a git repo, fall back to current directory
    save_on_close = true, -- unimplemented
    -- set `keymaps` to false to disable automatic keymap setup
    keymaps = {
        quit_save = "q", -- `q` in normal mode will save and close the buffer
    },
}
```

</details>
