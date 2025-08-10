-- [[ Neovim Configuration ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' ' -- space
vim.g.maplocalleader = ' ' -- space
-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true
-- Load core configuration
require 'core.options'
require 'core.keymaps'
require 'core.autocmds'
-- Load plugins
require 'plugins'
