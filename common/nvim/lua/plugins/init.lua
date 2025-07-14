-- [[ Plugin management ]]

-- NOTE: PLUGIN FORMATS
-- Simple: 'owner/repo' or { 'owner/repo' }
-- With options: { 'owner/repo', opts = {} } -> auto-calls setup()
-- With config: { 'owner/repo', config = function() ... end }
-- With dependencies: { 'owner/repo', dependencies = { 'dep1', 'dep2' } }
-- With lazy loading: { 'owner/repo', event = 'VimEnter' }

-- NOTE: USEFUL COMMANDS
-- :Lazy - check plugin status
-- :Lazy update - update all plugins
-- :checkhealth - debug installation issues
-- :help laz.nvim-plugin-spec - full plugin specifications

-- NOTE: TELESCOPE SEARCH
-- <space>sh -> "lazy.nvim-lugin" for more plugin help
-- <space>sr to resume last telescope search

-- [[ Install Lazy ]]
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Load pugins ]]
require('lazy').setup({
  { import = 'plugins.editor' },
  { import = 'plugins.lsp' },
  { import = 'plugins.completion' },
  { import = 'plugins.telescope' },
  { import = 'plugins.treesitter' },
  { import = 'plugins.ui' },
  -- NOTE: kickstart-included plugins
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
