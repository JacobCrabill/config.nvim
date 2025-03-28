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
  'norcalli/nvim-terminal.lua',
  'SmiteshP/nvim-navic',
  'sindrets/diffview.nvim',
  'voldikss/vim-floaterm',  -- Floating terminal buffers
  'mg979/vim-visual-multi', -- Multiple cursors

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
    build = ':TSUpdate',
    dependencies = { 'nvim-treesitter/playground' },
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
    'mrcjkb/rustaceanvim', -- Rust language support
    version = '^5',        -- Recommended
    lazy = false,          -- This plugin is already lazy
  },
  'neovim/nvim-lspconfig',
  'rhysd/vim-clang-format',
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'aklt/plantuml-syntax',
  'jjo/vim-cue',
  'fladson/vim-kitty', -- Kitty config syntax highlighting
  'folke/neodev.nvim' ,-- Lua & NeoVim API LSP support
  'Decodetalkers/neocmakelsp', -- CMake LSP
  'python-lsp/python-lsp-server',
  'tikhomirov/vim-glsl', -- OpenGL syntax

  -- TypeScript (ugh) support (FoxGlove)
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },

  -- ==== Misc Tools ==============================================
  -- Render code to a PNG image
  -- Prerequisites: See https://crates.io/crates/silicon
  --   cargo install silicon
  'segeljakt/vim-silicon',
  -- Colorize hex and RGB color codes
  'norcalli/nvim-colorizer.lua',

  -- In-buffer Markdown rendering
  'jacobcrabill/zigdown',
})

-- Add our Lua folder to the runtime path, and source its init.lua
local nvimrc = vim.fn.stdpath('config')
vim.opt.rtp:append(nvimrc .. '/lua')
require('init')
