Pattern Selector for Neovim to easy copy/paste/replace patterns.
<h1>Overview</h1>

Pattern Selector is a Neovim plugin designed to highlight and select patterns (like URLs, UUIDs, IP addresses, and tokens) for easy and simple copy. (idea from [thumbs-nvim](https://github.com/fcsonline/tmux-thumbs)), but will also replace the selected pattern with a new value. 

Use the `FindAndSelectPattern()` function which will highlight and assign a unique character to each match for quick selection. 

The `ReplaceWithClipboard()` function will replace what the selected item contains with the clipboard value.

Examples:

[Example for copy](https://giphy.com/gifs/BmwxVjTUqTfu9dZgJA)

[example for replace](https://giphy.com/gifs/Mfen6kZ4NXtIKks28Z)

<h2>Features:</h2>

- Highlight specific patterns (URLs, UUIDs, tokens, etc.) and assigns a unique character to each match for quick selection
- Copy the selected match to the clipboard
- Replace the selected match with a new value

<h2>Requirements</h2>

Neovim: Version 0.10 or higher, works on Linux. No external dependencies required.

<h2>Installation</h2>

lazy:
```lua
{
  "Xouzoura/pattern_selector",
  config = function(_, opts)
    require("pattern_selector").setup(opts)
    -- Set a keymap to call the pattern selector function
    vim.api.nvim_set_keymap(
      "n",
      "<leader>co",
      ":lua require('pattern_selector').FindAndSelectPattern()<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>cr",
      ":lua require('pattern_selector').ReplaceWithClipboard()<CR>",
      { noremap = true, silent = true }
    )
  end
}
```

<h4>Patterns</h4>
Patterns Supported

- URL (HTTP/HTTPS)
- UUID
- IP Address
- Tokens (starting with eyJ..)
- Hexadecimal Addresses (0x...)

The plugin uses the following functions:

- FindAndSelectPattern() - Highlights and assigns a unique character to each match for quick selection
- ReplaceWithClipboard() - Replaces the highlighted text with the value in the clipboard

<h1>Contributing</h1>

Feel free to fork and submit a pull request to add more patterns or suggest improvements. For bugs, create an issue in the GitHub repository. Not planning on expanding the plugin much, but will accept PRs.

<h1>License</h1>

This plugin is open-source and available under the MIT License.
