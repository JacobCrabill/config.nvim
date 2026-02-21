-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

vim.g.have_nerd_font = true

require('lazy').setup({
  'SmiteshP/nvim-navic',
  'sindrets/diffview.nvim',
  'voldikss/vim-floaterm',  -- Floating terminal buffers
  'mg979/vim-visual-multi', -- Multiple cursors
  'nvim-lua/plenary.nvim',

  { -- Telescope: Quickly search through files, integrate with LSP, etc.
      'nvim-telescope/telescope.nvim',
      event = 'VimEnter',
      branch = '0.1.x',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { -- If encountering errors, see telescope-fzf-native README for installation instructions
          'nvim-telescope/telescope-fzf-native.nvim',

          -- `build` is used to run some command when the plugin is installed/updated.
          -- This is only run then, not every time Neovim starts up.
          build = 'make',

          -- `cond` is a condition used to determine whether this plugin should be
          -- installed and loaded.
          cond = function()
            return vim.fn.executable 'make' == 1
          end,
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },

        -- Pretty icons; requires a Nerd Font.
        { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      },
  },


  -- ==== Code Completion ==========================================
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  -- For vsnip users. Do I use this?? idk
  'hrsh7th/vim-vsnip',
  'hrsh7th/cmp-vsnip',

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    tag = "v0.10.0",
    lazy = false,
    build = ':TSUpdate',
    -- dependencies = { 'nvim-treesitter/playground' },
  },
  'tpope/vim-fugitive', -- Nice Git integration
  -- 'tpope/vim-commentary'

  -- NvimTree - Excellet, configurable file browswer written in Lua
  'nvim-tree/nvim-tree.lua',

  -- Integration with Kitty for window navigation
  {
    'knubie/vim-kitty-navigator',
    build = 'cp ./*.py ~/.config/kitty/',
  },

  -- ==== Style Customization ======================================
  -- Color Schemes
  'sainnhe/forest-night',
  { 'catppuccin/nvim', name = 'catppuccin' },
  'drewtempelmeyer/palenight.vim',
  'rmehri01/onenord.nvim',
  'scottmckendry/cyberdream.nvim',
  'rebelot/kanagawa.nvim',
  'EdenEast/nightfox.nvim',
  'marko-cerovac/material.nvim',
  'folke/tokyonight.nvim',
  -- 'navarasu/onedark.nvim',
  'olimorris/onedarkpro.nvim',

  -- Fonts, icons, statusbars
  'nvim-lualine/lualine.nvim', -- Fancy status bar. Like Vim-Airline, but better
  'nvim-tree/nvim-web-devicons', -- Requires a NerdFont to be in use

  -- Keep Window, Close Buffer
  'rgarver/Kwbd.vim',

  -- ==== Debugging Support ========================================
  -- 'puremourning/vimspector'
  'mfussenegger/nvim-dap',
  'rcarriga/nvim-dap-ui',
  'nvim-neotest/nvim-nio', -- nvim-dap-ui says it's needed
  'nvim-telescope/telescope-dap.nvim',
  -- 'theHamsta/nvim-dap-virtual-text', -- didn't really like it; slows things down a lot
  'jacobcrabill/nvim-dap-utils',

  { -- Open-Windows Tab bar
    'romgrk/barbar.nvim',

    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
  },

  -- Highlight trailing whitespace
  'ntpeters/vim-better-whitespace',

  -- Escape ANSI sequences and colorize output
  'powerman/vim-plugin-AnsiEsc',

  -- ==== Language Support ========================================
  -- Language Servers Provider and other language suppport plugins
  'ziglang/zig.vim', -- Zig language support
  {
    'mrcjkb/rustaceanvim', version = '^5', -- Rust language support
  },
  'neovim/nvim-lspconfig',             -- Base Neovim LSP configurations
  'rhysd/vim-clang-format',            -- Clang auto-formatting
  'williamboman/mason.nvim',           -- The Mason tool: Easily install LSPs, linters, etc.
  'williamboman/mason-lspconfig.nvim', -- Auto LSP config for Mason
  'aklt/plantuml-syntax',
  'jjo/vim-cue',
  'fladson/vim-kitty', -- Kitty config syntax highlighting
  'folke/lazydev.nvim' ,-- Lua & NeoVim API LSP support
  'Decodetalkers/neocmakelsp', -- CMake LSP
  'python-lsp/python-lsp-server',
  'tikhomirov/vim-glsl', -- OpenGL syntax
  'norcalli/nvim-terminal.lua', -- "Terminal" filetype

  -- TypeScript (ugh) support (FoxGlove)
  -- {
  --   "pmizio/typescript-tools.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  --   opts = {},
  -- },

  -- ==== Misc Tools ==============================================
  -- Render code to a PNG image
  -- Prerequisites: See https://crates.io/crates/silicon
  --   cargo install silicon
  'segeljakt/vim-silicon',
  -- Colorize hex and RGB color codes
  'norcalli/nvim-colorizer.lua',

  -- Markdown side-pane rendering
  'jacobcrabill/zigdown',
  'jacobcrabill/hologram.nvim',

  -- Animated Cursor
  -- NOTE: Seems to break Zigdown for some reason!
  -- {
  --   "sphamba/smear-cursor.nvim",
  --   opts = {
  --     -- Smear cursor when switching buffers or windows.
  --     smear_between_buffers = false,

  --     -- Smear cursor when moving within line or to neighbor lines.
  --     -- Use `min_horizontal_distance_smear` and `min_vertical_distance_smear` for finer control
  --     smear_between_neighbor_lines = true,

  --     -- Draw the smear in buffer space instead of screen space when scrolling
  --     scroll_buffer_space = true,

  --     -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
  --     -- Smears and particles will look a lot less blocky.
  --     legacy_computing_symbols_support = true,

  --     -- Smear cursor in insert mode.
  --     -- See also `vertical_bar_cursor_insert_mode` and `distance_stop_animating_vertical_bar`.
  --     smear_insert_mode = false,
  --   },
  -- }
})

local nvimrc = vim.fn.stdpath('config')

-- Custom .vim file for things that just don't quite work in Lua
vim.cmd('source ' .. nvimrc .. '/vim/extra.vim')
vim.cmd('source ' .. nvimrc .. '/syntax/eos.vim')
vim.filetype.add({
  extension = {
    eos = 'eos',
    mdx = 'markdown',
  },
})

-- Add our Lua folder to the runtime path, and source its init.lua
vim.opt.rtp:append(nvimrc .. '/lua')
require('init')
