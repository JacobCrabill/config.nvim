-- Basic setup options
require('options')

-- Keybindings
require('maps')

-- Mason
require("mason").setup()

-- Nvim-Tree
require("nvim_tree_setup")

-- All custom Autocommands
require('autocmds')

-- Code Completion
require('cmp_setup')

-- Lualine (statusline)
require('lualine_setup')

-- Language Setup (LSPs)
require('lsp_setup')

-- Telescope
require('telescope_setup')

-- TreeSitter
require('ts_setup')

-- DAP (Debug Adapter Protocol)
require('dap_config')

-- Other odds and ends
require('misc')

-- Gitsigns: Git status tracking symbols
-- require('gitsigns_setup')

-- Colorschemes and general style config
require('style')

-- require('hologram').setup{
--     auto_display = true -- WIP automatic markdown image display, may be prone to breaking
-- }
