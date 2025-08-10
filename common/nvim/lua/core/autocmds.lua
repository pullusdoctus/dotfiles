-- [[ Basic Autocommands ]]
-- See `:help lua-guide-autocommands`
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
-- See `:help vim.hl.on_yank()`
autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
