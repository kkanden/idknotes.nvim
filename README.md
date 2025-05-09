there are probably dozens of other plugins that do this but i wanna take a shot
at making a plugin.

## Usage

The main functionality is encapsulated in the command `:IDKnotes` which opens
the global note. Under the hood it uses `require("idknotes).toggle_notes` which
takes an optional boolean argument specifying if a global or a project-based
note is to be opened (global by default).

If you try to open a project-based note in a project that does not yet have a
note, you will be prompted to enter the name of the project you want to
associate with the note.

> [!WARNING] Project-based notes currently work only in git repositories.

### Example configuration

Using `lazy.nvim`:

```lua
return {
    "kkanden/idknotes.nvim",
    config = function()
        local idknotes = require("idknotes")

        idknotes.setup() -- calling setup is required to make sure the plugin works

        -- global notes
        vim.keymap.set("n", "<leader>n", idknotes.toggle_notes)

        -- project-based notes
        vim.keymap.set(
            "n",
            "<leader>m",
            function() idknotes.toggle_notes(false) end
        )
    end,
}
```
