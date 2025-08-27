-- [[ UI ]]
return {
  -- Colorschemes
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  {
    'cpplain/flexoki.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('flexoki').setup {
        styles = {
          comments = { italic = true },
        },
        transparent_mode = true,
      }
    end,
  },
  {
    'vague2k/vague.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('vague').setup {
        styles = {
          comments = { italic = true },
        },
        transparent = true,
      }
    end,
  },
  {
    'thesimonho/kanagawa-paper.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('kanagawa-paper').setup {
        styles = {
          comments = { italic = true },
        },
        transparent = true,
      }
    end,
  },
  {
    'dasupradyumna/midnight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('midnight').setup {
        styles = {
          comments = { italic = true },
        },
        -- transparent_mode = true,
      }
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require('gruvbox').setup {
        styles = {
          comments = { italic = true },
        },
        transparent_mode = true,
      }
      vim.o.background = 'dark'
      vim.cmd.colorscheme 'flexoki'
    end,
  },
}
