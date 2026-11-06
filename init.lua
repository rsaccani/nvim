-- Neovim configuration for reading, reviewing and testing code written by agents.
-- Languages: PHP, Python, Swift. Requires Neovim 0.12+ (vim.pack, vim.lsp.config).

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Options ---------------------------------------------------------------

local o = vim.opt
o.number = true
o.relativenumber = true
o.signcolumn = 'yes'
o.cursorline = true
o.scrolloff = 8
o.wrap = false
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 250
o.mouse = 'a'
o.clipboard = 'unnamedplus'
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.list = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.completeopt = { 'menuone', 'noselect', 'popup' }

-- Plugins ---------------------------------------------------------------

vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/vim-test/vim-test',
})

-- Language servers ------------------------------------------------------

-- mason installs intelephense, basedpyright and ruff under its own prefix;
-- sourcekit-lsp comes with Xcode and is found on PATH.
require('mason').setup()

local mason_packages = { 'intelephense', 'basedpyright', 'ruff' }
vim.api.nvim_create_user_command('MasonInstallAll', function()
  vim.cmd('MasonInstall ' .. table.concat(mason_packages, ' '))
end, { desc = 'Install the language servers this config expects' })

-- Let ruff handle linting; basedpyright keeps types, hover and navigation.
vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = { typeCheckingMode = 'standard' },
    },
  },
})

vim.lsp.enable({ 'intelephense', 'basedpyright', 'ruff', 'sourcekit' })

vim.diagnostic.config({
  virtual_text = { current_line = true },
  severity_sort = true,
  float = { border = 'rounded' },
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    if client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
    -- Neovim already maps K, grr, gri, grn, gra, gO and Ctrl-]; gd is the one missing.
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = args.buf, desc = 'Go to definition' })
  end,
})

-- Treesitter ------------------------------------------------------------

local parsers = {
  'php', 'phpdoc', 'python', 'swift', 'lua', 'vim', 'vimdoc', 'bash',
  'json', 'yaml', 'toml', 'markdown', 'markdown_inline', 'html', 'javascript',
  'diff', 'gitcommit', 'git_rebase',
}
require('nvim-treesitter').install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Search ----------------------------------------------------------------

local fzf = require('fzf-lua')
-- Ctrl-q sends every result to the quickfix list (the default Alt-q needs
-- Option-as-Alt in the macOS terminal).
fzf.setup({ keymap = { fzf = { true, ['ctrl-q'] = 'select-all+accept' } } })
vim.keymap.set('n', '<leader>f', fzf.files, { desc = 'Find file' })
vim.keymap.set('n', '<leader>/', fzf.live_grep, { desc = 'Grep project' })
vim.keymap.set('n', '<leader>*', fzf.grep_cword, { desc = 'Grep word under cursor' })
vim.keymap.set('n', '<leader>b', fzf.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>s', fzf.lsp_document_symbols, { desc = 'Symbols in file' })
vim.keymap.set('n', '<leader>S', fzf.lsp_live_workspace_symbols, { desc = 'Symbols in project' })
vim.keymap.set('n', '<leader>r', fzf.lsp_references, { desc = 'References' })
vim.keymap.set('n', '<leader>d', fzf.diagnostics_workspace, { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>h', fzf.helptags, { desc = 'Help' })
vim.keymap.set('n', '<leader><leader>', fzf.resume, { desc = 'Resume last search' })

-- Git review ------------------------------------------------------------

local gitsigns = require('gitsigns')
gitsigns.setup({
  on_attach = function(buf)
    local map = function(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
    end
    map(']c', function() gitsigns.nav_hunk('next') end, 'Next hunk')
    map('[c', function() gitsigns.nav_hunk('prev') end, 'Previous hunk')
    map('<leader>gp', gitsigns.preview_hunk, 'Preview hunk')
    map('<leader>gb', gitsigns.blame_line, 'Blame line')
  end,
})

require('diffview').setup({})
-- Review an agent's branch: every file it touched against the merge base with main.
vim.keymap.set('n', '<leader>gr', '<cmd>DiffviewOpen origin/HEAD...HEAD<cr>', { desc = 'Review branch' })
vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = 'Diff working tree' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history' })
vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<cr>', { desc = 'Close diff' })

-- Tests -----------------------------------------------------------------

vim.g['test#strategy'] = 'neovim_sticky'
vim.g['test#neovim#term_position'] = 'botright 15'
vim.keymap.set('n', '<leader>tn', '<cmd>TestNearest<cr>', { desc = 'Test nearest' })
vim.keymap.set('n', '<leader>tf', '<cmd>TestFile<cr>', { desc = 'Test file' })
vim.keymap.set('n', '<leader>ts', '<cmd>TestSuite<cr>', { desc = 'Test suite' })
vim.keymap.set('n', '<leader>tl', '<cmd>TestLast<cr>', { desc = 'Test last' })
vim.keymap.set('n', '<leader>tv', '<cmd>TestVisit<cr>', { desc = 'Open last test file' })

-- Small conveniences ----------------------------------------------------

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>')
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Leave terminal mode' })

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.hl.on_yank() end,
})
