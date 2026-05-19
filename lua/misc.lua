-- Zigdown (side-pane Markdown previewer and formatter)
require('zigdown').setup({ format_width = 100 })

-- -- Setup Silicon's options
-- vim.g.silicon = {
--   theme               = 'OneHalfDark',
--   background          = '#000000',
--   ['pad-horiz']       = 0,
--   ['pad-vert']        = 0,
--   ['window-controls'] = false,
--   output = '~/Documents/Silicon/silicon-{time:%Y-%m-%d-%H%M%S}.png',
--   to_clipboard = true,
-- }

-- Terminal filetype (renders most ANSI escape codes)
require('terminal').setup()

-- Proper viewing of log files with ANSI escape codes
local function ANSIEscapeLogFile()
  vim.cmd([[
  :AnsiEsc
  :StripWhitespace
  silent! :execute '! dos2unix -f %' | silent edit! %
  silent! :execute '%s/\r//g'
  ]])
end
vim.api.nvim_create_user_command('ANSILog', ANSIEscapeLogFile, {})

-- Colorizer Setup
-- Color the background of any hex or RGB color codes
local color_files = { '*' }
local colorizer_opts = {
  RGB = false,
  names = false,
  RRGGBBAA = true,
  -- Enable parsing rgb(...) and hsl(...) functions in css and html
  rgb_fn = true,
  hsl_fn = true,
}
require('colorizer').setup(color_files, colorizer_opts)

-- Turn inline diagnostics on/off
-- Helpful for large repos that are non-standards compliant
vim.api.nvim_create_user_command('DisableDiagnostics', function() vim.diagnostic.enable(false) end, {})
vim.api.nvim_create_user_command('EnableDiagnostics', function() vim.diagnostic.enable(true) end, {})

-- Use Neovim as a Hex Editor
vim.api.nvim_create_user_command('HexEditOpen', '%!xxd', {})
vim.api.nvim_create_user_command('HexEditClose', '%!xxd -r', {})

-- snake_case to CamelCase
-- Note that it has to be a keybind, not a command, due to operating in Visual mode
-- vim.api.nvim_create_user_command('SnakeToCamel', [[:<C-U>s#\%V\(\%(\<\l\+\)\%(_\)\@=\)\|_\(\l\)\%V#\u\1\2#g<CR>]], {})
vim.keymap.set("v", "<leader>n", [[:s#\%V\(\%(\<\l\+\)\%(_\)\@=\)\|_\(\l\)\%V#\u\1\2#g<CR>]], nil)

-- Proper viewing of log files with ANSI escape codes
local function CleanupHMTestLog()
  vim.cmd([[
  silent! :execute '%s/\[0m//g'
  silent! :execute '%s/\[91m//g'
  silent! :execute '%s/\[92m//g'
  silent! :execute '%s/\[93m//g'
  silent! :execute '%s/\[94m//g'
  silent! :execute '%s/\[95m//g'
  silent! :execute '%s/\[96m//g'
  silent! :execute '%s/\[97m//g'
  silent! :execute '%s/\[31m//g'
  silent! :execute '%s/\[32m//g'
  silent! :execute '%s/\[33m//g'
  :StripWhitespace
  ]])
end
vim.api.nvim_create_user_command('CleanupHMTestLog', CleanupHMTestLog, {})

-- Use 'jq' to format the current buffer
vim.api.nvim_create_user_command('JQ', '% !jq', {})
