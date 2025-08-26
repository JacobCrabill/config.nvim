-- Autocommand group for auto-formatters
vim.api.nvim_create_augroup('AutoFmt', {})
vim.api.nvim_create_augroup('OnOpen', {})
vim.api.nvim_create_augroup('vimrc', {})

vim.g.fmt_enable_exclusions = true
vim.g.autoformat_enabled = true
vim.g.cue_fmt_on_save = true
vim.g.markdown_formatter = 'zigdown'

vim.g["clang_format#detect_style_file"] = 1
vim.g["clang_format#enable_fallback_style"] = 0

-- Reset cursor to last location when opening file (marker '"')
vim.api.nvim_create_autocmd('BufReadpost', {
  pattern = { '*' },
  group = 'OnOpen',
  callback = function()
    vim.api.nvim_command([[if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]])
  end
})

-- Disable trailing whitespace highlighting for Markdown previews
vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
  pattern = { '*.mdp', 'zd-render' },
  group = 'OnOpen',
  callback = "DisableWhitespace",
})

-- Reset tabstop to 2 on opening a new file (for clangd)
vim.api.nvim_create_autocmd('BufReadpost', {
  pattern = { '*' },
  group = 'OnOpen',
  callback = function()
    vim.opt.tabstop=2
  end
})

-- Strip trailing whitespace
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'AutoFmt',
  callback = function()
    if vim.g.autoformat_enabled then
      vim.api.nvim_command([[:StripWhitespace]])
    end
  end
})

-- Set the XML filetype for ROS launch files
vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
  pattern = { '*.launch' },
  group = 'OnOpen',
  callback = function()
    vim.api.nvim_command([[set syntax=xml]])
  end
})

-- Set the GLSL (OpenGL) filetype for shader (.fs and .vs) files
vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
  pattern = { '*.fs', '*.vs' },
  group = 'OnOpen',
  callback = function()
    vim.api.nvim_command([[set syntax=glsl]])
  end
})

-- C/C++ auto-formatter (Clang-Format)
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.c', '*.cpp', '*.h', '*.hpp' },
  group = 'AutoFmt',
  callback = function()
    if vim.g.autoformat_enabled then
      vim.api.nvim_command([[:ClangFormat]])
    end
  end
})

-- Python auto-formatter (Black)
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.py' },
  group = 'AutoFmt',
  callback = function()
    -- Paths listed here will be excluded from autoformatting with black
    local exclude_paths = { }

    local path = vim.fn.expand('%:p')
    local excluded = false
    if vim.g.fmt_enable_exclusions then
      for _, exclusion in ipairs(exclude_paths) do
        if string.find(path, exclusion, 1) then
          excluded = true
          break
        end
      end
    end

    if vim.g.autoformat_enabled and excluded == false then
      vim.api.nvim_command([[silent write | silent :execute '! black %' | edit! %]])
    end
  end
})

-- CMake auto-formatter
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { 'CMakeLists.txt', '*.cmake' },
  group = 'AutoFmt',
  callback = function()
    -- Paths listed here will be excluded from cmake-format
    local exclude_paths = { }

    local path = vim.fn.expand('%:p')
    local excluded = false
    if vim.g.fmt_enable_exclusions then
      for _, exclusion in ipairs(exclude_paths) do
        if string.find(path, exclusion, 1) then
          excluded = true
          break
        end
      end
    end

    if vim.g.autoformat_enabled and excluded == false then
      vim.api.nvim_command([[silent write | silent :execute '! cmake-format --in-place %' | edit! %]])
    end
  end
})

-- Enable/Disable auto-formatting of CMake files in specific folders
function ToggleCMakeExclusions()
  vim.g.fmt_enable_exclusions = not vim.g.fmt_enable_exclusions
  vim.api.nvim_command([[ echo printf("CMake-format exclusions enabled set to: %d", g:fmt_enable_exclusions) ]])
end
vim.keymap.set('n', '<Leader>ex', ToggleCMakeExclusions)
vim.api.nvim_create_user_command('CMakeFmtToggleExclude', ToggleCMakeExclusions, {})

-- Markdown auto-formatter
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.md' },
  group = 'AutoFmt',
  callback = function()
    if vim.g.autoformat_enabled then
      -- Use the chosen Markdown formatter tool
      if vim.g.markdown_formatter == 'zigdown' then
        vim.api.nvim_command([[ZigdownFormat]])

      elseif vim.g.markdown_formatter == 'mdformat' then
        vim.api.nvim_command([[silent write | silent :execute '! mdformat --wrap 100 --end-of-line keep %' | edit! %]])
      end
    end
  end
})

-- HTML auto-formatter
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.html', '*.htmx', '*.htm' },
  group = 'AutoFmt',
  callback = function()
    if vim.g.autoformat_enabled then
      vim.api.nvim_command([[silent write | silent :execute '! superhtml fmt %' | edit! %]])
    end
  end
})

-- Enable/Disable format-on-save for all languages
function DisableAutoFmt()
  vim.g.autoformat_enabled = false
  vim.g.cue_fmt_on_save = false -- CUE Format is handled separately
end
function EnableAutoFmt()
  vim.g.autoformat_enabled = true
  vim.g.cue_fmt_on_save = true
end
vim.api.nvim_create_user_command('DisableAutoFmt', DisableAutoFmt, {})
vim.api.nvim_create_user_command('EnableAutoFmt', EnableAutoFmt, {})

-- Create a new Floaterm on startup, hide it, then setup ctrl+t to toggle it
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = { '*' },
  group = 'vimrc',
  callback = function()
    vim.cmd([[:FloatermKill!]])
    vim.cmd([[:FloatermNew]])
    vim.cmd([[:stopinsert]])
    vim.cmd([[:FloatermHide]])
  end
})
