-- [[ UI ]]
return {
  { -- Colorscheme
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'ellisonleao/gruvbox.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('gruvbox').setup {
        styles = {
          comments = { italic = true }, -- Enable italics in comments
        },
      }
      -- Load the colorscheme here.
      vim.o.background = 'dark'
      vim.cmd.colorscheme 'gruvbox'
    end,
  },
}
