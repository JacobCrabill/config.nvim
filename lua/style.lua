-- Enable transparent background (Or rather, use terminal's background)
-- Equivalent to: hi Normal guibg=none ctermbg=none
vim.api.nvim_set_hl(0, 'Normal', { bg=0 })
vim.api.nvim_set_hl(0, 'NonText', { bg=0 })
vim.opt.background = 'dark'

-- Colorscheme Selection
vim.g.my_scheme = "tokyonight"     -- Option for dark mode (default)
vim.g.my_light_scheme = "dayfox" -- Option for light mode

-- My custom color definitions
local my_colors = {
  comment_pink = "#ee55a0",
  comment_pink_2 = "#c69fd6",
  comment_coral = "#d46398",
  purple = "#C792EA",
  purple2 = "#9C82D9",
  purple_grey = "#5D4F68",
  dark_purple = "#B480D6",
  coral = "#FF9CAC",
  lime = "#BFD982",
  baby_pink = "#D96293",
  lime_green = "#99EE00",
}

-- OneDark Color Scheme config
require('onedark').setup({
  style = 'dark',
  transparent = true,

  -- toggle theme style ---
  -- toggle_style_key = "<leader>ts",
  -- Available styles: dark(er), cool, deep, warm(er)
  toggle_style_list = {'dark', 'darker', 'cool', 'warm'},

  -- Turn off italics for comments
  code_style = {
      comments = 'none',
  },

  colors = {
    comment_pink = my_colors.comment_pink
  },

  highlights = {
    -- Treesitter token types
    ["@Comment"] = {fg = '$comment_pink'},
    -- Built-in token types
    Comment = {fg = '$comment_pink'},
    -- LSP token types
    ["@lsp.type.comment"] = { fg = '$comment_pink' },
  }
})
-- require('onedark').load()

-- Tokyo Night style
require("tokyonight").setup({
  style = "storm", -- storm, moon, night, light
  transparent = true,
  on_colors = function(colors)
    colors.comment = my_colors.comment_coral
  end
})

-- Material theme
require("material").setup({
    contrast = {
      terminal = false, -- Enable contrast for the built-in terminal
      sidebars = true, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
      floating_windows = true, -- Enable contrast for floating windows
      cursor_line = false, -- Enable darker background for the cursor line
      non_current_windows = false, -- Enable contrasted background for non-current windows
      filetypes = {}, -- Specify which filetypes get the contrasted (darker) background
  },

  disable = {
    background = true,
  },

  high_visibility = {
      lighter = false, -- Enable higher contrast text for lighter style
      darker = false, -- Enable higher contrast text for darker style
  },

  lualine_style = "default",

  plugins = {
    "nvim-tree",
    "telescope",
    "noice",
    "nvim-cmp",
  },

  custom_colors = function(colors)
    colors.syntax.comments = "#EA9892" -- "#FF7878"
    colors.editor.line_numbers = my_colors.purple_grey
    colors.editor.cursor = my_colors.lime_green
  end
})

-- Nightfox Setup
require('nightfox').setup({
  options = {
    transparent = false,
  },
  -- styles = {               -- Style to be applied to different syntax groups
  --   comments = "italic",   -- Value is any valid attr-list value `:help attr-list`
  -- },
  -- palettes = {
  --   all = {
  --     comment = my_colors.comment_pink,
  --   },
  -- },
})

if vim.g.my_scheme == "material" then
  -- vim.cmd('colorscheme material-palenight')
  vim.cmd('colorscheme material-darker')

elseif vim.g.my_scheme == "onedark" then
  vim.cmd('colorscheme onedark')

elseif vim.g.my_scheme == "nightfox" then
  vim.cmd('colorscheme duskfox')

elseif vim.g.my_scheme == "palenight" then
  vim.cmd('colorscheme palenight')
  vim.g.palenight_terminal_italics = 1
  -- Note: I think LSP highlighting is overriding this
  vim.g.palenight_color_overrides = {
    comment_grey = { gui = "#EE55E0", cterm = "213", cterm16 = "13" }
  }

elseif vim.g.my_scheme == "tokyonight" then
  vim.cmd('colorscheme tokyonight')

end

-- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

--------------------------------------------------------------------------
-- Toggle Light / Dark Themes
--------------------------------------------------------------------------

vim.g.bg_is_dark = true

-- Set colorscheme to the Outdoors / Light theme
function SetBackgroundLight()
  -- Set to Light
  vim.print("Toggle to Light")
  vim.api.nvim_set_hl(0, 'Normal', { bg="White", fg="Black" })
  vim.api.nvim_set_hl(0, 'NonText', { bg="White", fg="Black" })
  vim.opt.background = 'light'
  vim.cmd('colorscheme ' .. vim.g.my_light_scheme)
  vim.g.bg_is_dark = false
end

-- Set colorscheme to the Normal / Dark theme
function SetBackgroundDark()
    -- Set to Dark
    vim.print("Toggle to Dark")
    vim.api.nvim_set_hl(0, 'Normal', { bg=0 })
    vim.api.nvim_set_hl(0, 'NonText', { bg=0 })
    vim.opt.background = 'dark'
    vim.cmd('colorscheme ' .. vim.g.my_scheme)
    vim.g.bg_is_dark = true
end

-- Toggle between Light and Dark
function ToggleBackground()
  if vim.g.bg_is_dark == true then
    SetBackgroundLight()
  else
    SetBackgroundDark()
  end
end

vim.api.nvim_create_user_command('ToggleBackground', ToggleBackground, {})
vim.api.nvim_create_user_command('SetBackgroundDark', SetBackgroundDark, {})
vim.api.nvim_create_user_command('SetBackgroundLight', SetBackgroundLight, {})

