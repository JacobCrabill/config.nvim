-- Zigdown (side-pane Markdown renderer)
require('zigdown').setup()

-- Setup Silicon's options
vim.g.silicon = {
  theme               = 'OneHalfDark',
  background          = '#000000',
  ['pad-horiz']       = 0,
  ['pad-vert']        = 0,
  ['window-controls'] = false,
  output = '~/Documents/Silicon/silicon-{time:%Y-%m-%d-%H%M%S}.png',
}

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
