Pattern Selector Neovim Plugin
<h1>Overview</h1>

Pattern Selector is a Neovim plugin designed to highlight and select patterns like URLs, UUIDs, IP addresses, and tokens for easy selection and copying. (idea from [thumbs-nvim](https://github.com/fcsonline/tmux-thumbs))

<h2>Features:</h2>

    - Highlight specific patterns (URLs, UUIDs, tokens, etc.)
    - Assigns a unique character to each match for quick selection
    - Copy the selected match to the clipboard

<h2>Requirements</h2>

Neovim: Version 0.10 or higher

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
  end
}
```

<h4>Patterns</h4>
Patterns Supported

    URL (HTTP/HTTPS)
    UUID
    IP Address
    Tokens (starting with eyJ)
    Hexadecimal Addresses (0x...)

<h1>Contributing</h1>
Feel free to fork and submit a pull request to add more patterns or suggest improvements. For bugs, create an issue in the GitHub repository.

License

This plugin is open-source and available under the MIT License.
