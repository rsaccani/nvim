# nvim

A small Neovim configuration for reading, reviewing and testing code that agents write.
It covers PHP, Python and Swift, and replaces [rsaccani/vimrc](https://github.com/rsaccani/vimrc).

## Requirements

- Neovim 0.12 or later (plugins are managed by the built-in `vim.pack`)
- `brew install fzf ripgrep fd tree-sitter-cli`
- Xcode, for `sourcekit-lsp`

## Installation

```sh
git clone https://github.com/rsaccani/nvim ~/.config/nvim
nvim                 # confirm the plugin install; parsers compile in the background
:MasonInstallAll     # intelephense, basedpyright, ruff
```

Plugin revisions are pinned in `nvim-pack-lock.json`; update with `:lua vim.pack.update()`.

## Language servers

| Language | Server | Notes |
|---|---|---|
| PHP | intelephense | The free tier covers navigation, hover and diagnostics. |
| Python | basedpyright, ruff | basedpyright handles types and navigation; ruff handles linting. |
| Swift | sourcekit-lsp | Works with SwiftPM packages. Xcode projects need [xcode-build-server](https://github.com/SolaWing/xcode-build-server). |

## Shortcut guide

The leader key is Space, so `<leader>f` means Space then f.
`:map <leader>` lists every leader mapping with its description.

### Reading code

Put the cursor on a name and use:

| Key | Action |
|---|---|
| `gd` | Go to the definition |
| `Ctrl-o` / `Ctrl-i` | Jump back / forward through where you have been; use it after every `gd` |
| `K` | Show type and documentation in a floating window (press `K` again to enter it) |
| `grr` | List every reference in the quickfix list |
| `gri` | Go to the implementation of an interface or abstract method |
| `gO` | Outline of the current file |
| `]d` / `[d` | Next / previous diagnostic; `Ctrl-w d` shows the full message |

### Searching

| Key | Action |
|---|---|
| `<leader>f` | Find a file by name |
| `<leader>/` | Grep the whole project as you type |
| `<leader>*` | Grep the word under the cursor |
| `<leader>s` / `<leader>S` | Find a symbol in this file / in the whole project |
| `<leader>r` | References of the symbol under the cursor, with preview |
| `<leader>d` | All diagnostics in the project |
| `<leader>b` | Open buffers |
| `<leader><leader>` | Reopen the last search where you left it |

Inside a search window, type to filter, `Enter` opens, `Ctrl-v` / `Ctrl-s` / `Ctrl-t`
open in a vertical split / horizontal split / tab, and `Tab` marks several entries.
`Ctrl-q` sends every result to the quickfix list, which you then walk with
`]q` / `[q` and reopen with `:copen`. `F1` shows the remaining keys.

### Reviewing an agent's branch

| Key | Action |
|---|---|
| `<leader>gr` | Open every file the branch changed against `origin/HEAD`, side by side |
| `<leader>gd` | Same for uncommitted changes in the working tree |
| `<leader>gh` | History of the current file, one commit at a time |
| `<leader>gq` | Close the diff view |

Inside the diff view, `Tab` / `Shift-Tab` move to the next / previous file, `gf` opens
the file for editing, and `g?` shows the remaining keys. There `<leader>b` hides the
file list instead of listing buffers.

In a normal buffer, the sign column marks lines changed since the last commit:

| Key | Action |
|---|---|
| `]c` / `[c` | Next / previous change |
| `<leader>gp` | Preview the change under the cursor |
| `<leader>gb` | Who changed this line, and in which commit |

Outside Neovim, `git dft` shows uncommitted changes and `git dlog` shows history,
both through difftastic, which compares syntax trees so that moved or re-indented
code does not show up as a rewrite.

### Running tests

From inside a test file:

| Key | Action |
|---|---|
| `<leader>tn` | Run the test under the cursor |
| `<leader>tf` | Run the whole file |
| `<leader>ts` | Run the suite |
| `<leader>tl` | Run the last test again, from any file |
| `<leader>tv` | Go back to the last test file |

Output appears in a terminal at the bottom; `Esc Esc` leaves terminal mode so you
can scroll and copy.

### Windows

| Key | Action |
|---|---|
| `Ctrl-w v` / `Ctrl-w s` | Split vertically / horizontally |
| `Ctrl-w h/j/k/l` | Move between windows |
| `Ctrl-w o` | Keep only the current window |
| `Ctrl-w q` | Close the window |
