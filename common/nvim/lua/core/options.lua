-- [[ Setting options ]]
-- See `:help opt`
-- See `:help lua-options` and `:help lua-options-guide`
-- For more options, you can see `:help option-list`
local opt = vim.opt
local lopt = vim.opt_local
local autocmd = vim.api.nvim_create_autocmd

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Mouse mode
opt.mouse = 'a'

-- Don't show mode in cmd
opt.showmode = false

-- Sync Neovim & OS clipboards
-- See `:help 'clipboard'`
vim.schedule(function()
  opt.clipboard = 'unnamedplus'
end)

-- Indentation
opt.breakindent = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
autocmd('FileType', { -- Python Indentation
  pattern = 'python',
  callback = function()
    lopt.expandtab = true
    lopt.tabstop = 4
    lopt.shiftwidth = 4
    lopt.softtabstop = 4
  end,
})
autocmd('FileType', { -- X86 Assembly Indentation (NASM)
  pattern = { 'asm', 'nasm' },
  callback = function()
    lopt.expandtab = false
    lopt.tabstop = 8
    lopt.shiftwidth = 8
    lopt.softtabstop = 8
  end,
})

-- Stopline
opt.colorcolumn = ''
autocmd('FileType', { -- C/C++, HTML/CSS, Java/TypeScript @ column 80
  pattern = { 'c', 'cpp', 'h', 'hpp', 'js', 'ts' },
  callback = function()
    lopt.colorcolumn = '80'
  end,
})
autocmd('FileType', { -- Python @ column 100
  pattern = 'python',
  callback = function()
    lopt.colorcolumn = '100'
  end,
})
autocmd('FileType', { -- HTML/CSS @ column 120
  pattern = { 'html', 'css' },
  callback = function()
    lopt.colorcolumn = '120'
  end,
})

-- Undo History
opt.undofile = true

-- Case-insensitve search UNLESS \C or 1+ capital letters in query
opt.ignorecase = true
opt.smartcase = true

-- UI
opt.signcolumn = 'yes'
opt.updatetime = 250
opt.timeoutlen = 300

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Whitespace
-- See `:help 'list'` and `:help 'listchars'`
-- Notice listchars is set using `vim.opt` instead of `vim.o`.
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Substitution
opt.inccommand = 'split'

-- Cursor
opt.cursorline = true
opt.scrolloff = 10

-- Confirm
-- See `:help 'confirm'`
opt.confirm = true

-- vim: ts=2 sts=2 sw=2 et
