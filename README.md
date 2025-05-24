IDKnotes (notice the silent "k") because idk what i'm doing wasting my time on
something that has probably been implemented dozens of times already in a better
way.

## Usage

The plugin is based upon a single user command `:IDKnotes` which takes optional
arguments. If no argument is provided, the global notes are opened; with a bang
(`:IDKnotes!`), the project notes are opened (see below).

Upon trying to open a project note in a project for which a project note has not
yet been created, you will be prompted to provide a name associated with the
project.

### Available commands

The `:IDKnotes` command accepts the following subcommands:

- `rename` - opens prompt to enter new of the current project's note;
- `delete` - deletes the current project note;
- `manage` - opens picker to do the above actions on a chosen project note;
- `share [project_name]` - applies `project_name`'s note in the current project,
  will override an existing project note.

## Configuration

Example configuration using `lazy.nvim`:

```lua
{
    "kkanden/idknotes.nvim",
    ---@type idknotes.Config
    opts = {},
    keys = { -- suggested keymaps
        {
            "<leader>n",
            "<Cmd>IDKnotes<CR>",
        },
        {
            "<leader>m",
            "<Cmd>IDKnotes!<CR>",
        },
    },
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
    save_on_close = true,
    -- set `keymaps` to false to disable automatic keymap setup
    keymaps = {
        quit_save = "q", -- `q` in normal mode will save and close the buffer
    },
}
```

</details>
