-- Enable transparent background (Or rather, use terminal's background)
-- Equivalent to: hi Normal guibg=none ctermbg=none
vim.api.nvim_set_hl(0, 'Normal', { bg=0 })
vim.api.nvim_set_hl(0, 'NonText', { bg=0 })
vim.opt.background = 'dark'

-- Colorscheme Selection
vim.g.my_scheme = "catppuccin-frappe"             -- Option for dark mode (default)
vim.g.my_light_scheme = "catppuccin-latte" -- Option for light mode
vim.g.transparent = true

-- My custom color definitions
local my_colors = {
  comment_pink = "#ee55a0",
  comment_pink_2 = "#c69fd6",
  comment_coral = "#dd7799",
  purple = "#C792EA",
  purple2 = "#9C82D9",
  light_purple = "#DACAF4",
  purple_grey = "#5D4F68",
  dark_purple = "#B480D6",
  coral = "#FF9CAC",
  lime = "#BFD982",
  baby_pink = "#D96293",
  lime_green = "#99EE00",
  mint = "#61ff81",
  pastel_mint = "#6FFFD4",
  pale_blue = "#9EC4E4",
}

-- Tokyo Night style
local function setup_tokyonight()
  require("tokyonight").setup({
    style = "storm", -- storm, moon, night, light
    transparent = vim.g.transparent,
    on_colors = function(colors)
      colors.comment = my_colors.comment_coral
    end
  })
end

-- Material theme
local function setup_material()
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
      background = vim.g.transparent,
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
end

-- Nightfox Setup
local function setup_nightfox()
  require('nightfox').setup({
    options = {
      transparent = vim.g.transparent,
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
end

-- OneDark Color Scheme config (onedark.nvim)
local function setup_onedark()
  require('onedark').setup({
    style = 'dark',
    transparent = vim.g.transparent,

    -- toggle theme style ---
    toggle_style_key = "<leader>od",
    -- Available styles: dark(er), cool, deep, warm(er)
    toggle_style_list = {'dark', 'darker', 'cool', 'warm'},

    -- Turn off italics for comments
    code_style = {
        comments = 'none',
    },

    colors = {
      comment_pink = my_colors.comment_pink,
      lime_green = my_colors.lime_green,
    },

    highlights = {
      -- Treesitter token types
      ["@Comment"] = {fg = '$comment_pink'},
      -- Built-in token types
      Comment = {fg = '$comment_pink'},
      -- LSP token types
      ["@lsp.type.comment"] = { fg = '$comment_pink' },
      -- BarBar tabs
      BufferCurrent = { fg = '$mint', bg = '$purple2' },
    }
  })
  -- require('onedark').load()
end

-- OneDark Pro Color Scheme config (onedarkpro.nvim)
local function setup_onedarkpro()
  local onedarkpro = require('onedarkpro')
  onedarkpro.clean()
  onedarkpro.setup({
    colors = my_colors,
    highlights = {
      Comment = { fg = "${comment_coral}" },
      BufferCurrent = { fg = '${black}', bg = "${blue}" }, -- BarBar's active tab
      -- BufferCurrent = { fg = '${mint}', bg = "${purple2}" }, -- BarBar's active tab
      BufferCurrentBtn = { fg = '${black}', bg = "${blue}" }, -- BarBar's active tab
      BufferCurrentMod = { fg = '${orange}', bg = "${blue}" }, -- BarBar's active tab (modified)
      -- BufferCurrentIcon = { fg = '${black}', bg = "${yellow}" }, -- BarBar's active tab (modified)
      ["@variable"] = { fg = '${fg}' },
      -- ["@variable"] = { fg = '${pale_blue}' },
      ["@property"] = { fg = '${comment}' },
      -- ["@property"] = { fg = '${pale_blue}' },
      ["@parameter"] = { fg = '${cyan}' },
    },
    options = {
      transparency = true,
    }
  })
end

local function setup_catppuccin()
  local catppuccin = require('catppuccin')
  catppuccin.setup{
    flavour = "frappe",
    transparent_background = false,
    color_overrides = {
      frappe = {
        rosewater = "#f2d5cf",
        flamingo = "#eebebe",
        pink = "#f4b8e4",
        mauve = "#c290ea",
        red = "#e78284",
        maroon = "#ea999c",
        peach = "#ef9f76",
        yellow = "#e2c483",
        green = "#9ad48d",
        teal = "#81c8be",
        sky = "#99d1db",
        sapphire = "#85c1dc",
        blue = "#83a7fc",
        lavender = "#babbf1",
        text = "#c9d8fd",
        subtext1 = "#b5bfe2",
        subtext0 = "#a5adce",
        overlay2 = "#949cbb",
        overlay1 = "#838ba7",
        overlay0 = "#737994",
        surface2 = "#626880",
        surface1 = "#51576d",
        surface0 = "#414559",
        base = "#303446",
        mantle = "#292c3c",
        crust = "#232634",
      },
    },
    custom_highlights = function(colors)
      return {
        ["@markup.link.url"] = { fg = colors.blue, },
        ["@markup.raw"] = { fg = colors.mauve, },
      }
    end,
    integrations = {
      barbar = true,
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = false,
      navic = {
        enabled = true,
        -- custom_bg = "NONE",
      },
      mini = {
          enabled = true,
          indentscope_color = "",
      },
      -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
  }
end

local function setup_onenord()
  require('onenord').setup({
    borders = true, -- Split window borders
    fade_nc = false, -- Fade non-current windows, making them more distinguishable
    -- -- Style that is applied to various groups: see `highlight-args` for options
    -- styles = {
    --   comments = "NONE",
    --   strings = "NONE",
    --   keywords = "NONE",
    --   functions = "NONE",
    --   variables = "NONE",
    --   diagnostics = "underline",
    -- },
    disable = {
      background = false, -- Disable setting the background color
      float_background = false, -- Disable setting the background color for floating windows
      cursorline = false, -- Disable the cursorline
      eob_lines = true, -- Hide the end-of-buffer lines
    },
    -- Inverse highlight for different groups
    inverse = {
      match_paren = false,
    },
    custom_highlights = {}, -- Overwrite default highlight groups
    custom_colors = {}, -- Overwrite default colors
  })
end

if vim.g.my_scheme == "material" then
  setup_material()
  vim.cmd('colorscheme material-palenight')
  -- vim.cmd('colorscheme material-darker')

elseif string.find(vim.g.my_scheme, "onedark") then
  setup_onedarkpro()
  vim.cmd('colorscheme ' .. vim.g.my_scheme)

elseif vim.g.my_scheme == "nightfox" then
  setup_nightfox()
  vim.cmd('colorscheme duskfox')

elseif vim.g.my_scheme == "palenight" then
  vim.cmd('colorscheme palenight')
  vim.g.palenight_terminal_italics = 1
  -- Note: I think LSP highlighting is overriding this
  vim.g.palenight_color_overrides = {
    comment_grey = { gui = "#EE55E0", cterm = "213", cterm16 = "13" }
  }

elseif vim.g.my_scheme == "tokyonight" then
  setup_tokyonight()
  vim.cmd('colorscheme tokyonight')

elseif vim.g.my_scheme == "catppuccin" then
  setup_catppuccin()
  vim.cmd('colorscheme catppuccin')

elseif vim.g.my_scheme == "onenord" then
  setup_onenord()
  vim.cmd('colorscheme onenord')

else
  vim.cmd('colorscheme ' .. vim.g.my_scheme)
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

