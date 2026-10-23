-- Everything in ci-templates is hidden, so change settings
-- Allow some repos to search hidden files (besides '.git')
local hidden_projects = { '/home/jcrabill/Codes/ci-templates' }

local should_show_hidden = function(dir)
  for _, project in ipairs(hidden_projects) do
    if string.find(dir, project) or dir == project then
      return true
    end
  end
  return false
end

local cwd = vim.loop.cwd()
local show_hidden = should_show_hidden(cwd)
local use_gitignore = true

local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")

-- Prevent Neovim/Tree-sitter/syntax rendering from freezing on files with long lines
-- (e.g. minified JS, single-line JSON/SVG, jupyter notebooks) or binary files without newlines.
local MAX_LINE_LENGTH = 256
local MAX_FILE_SIZE = 500 * 1024 -- 500 KB

local custom_buffer_previewer_maker = function(filepath, bufnr, opts)
  opts = opts or {}
  filepath = vim.fn.expand(filepath)

  -- If already loaded for this buffer, use default callback handling
  if opts.bufname == filepath then
    previewers.buffer_previewer_maker(filepath, bufnr, opts)
    return
  end

  local uv = vim.uv or vim.loop

  -- Fast path: skip previewing known problematic heavy formats immediately
  if filepath:match("%.ipynb$") or filepath:match("%.min%.js$") or filepath:match("%.min%.css$") then
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        local msg = "Preview skipped for this file type"
        if opts.winid and vim.api.nvim_win_is_valid(opts.winid) then
          putils.set_preview_message(bufnr, opts.winid, msg)
        else
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { msg })
        end
      end
    end)
    return
  end

  uv.fs_stat(filepath, function(stat_err, stat)
    if stat_err or not stat then
      previewers.buffer_previewer_maker(filepath, bufnr, opts)
      return
    end

    if stat.type == "directory" then
      previewers.buffer_previewer_maker(filepath, bufnr, opts)
      return
    end

    -- Reject files exceeding size limit immediately before opening/reading
    if stat.size > MAX_FILE_SIZE then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          if opts.winid and vim.api.nvim_win_is_valid(opts.winid) then
            putils.set_preview_message(bufnr, opts.winid, "File exceeds preview size limit")
          else
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "File exceeds preview size limit" })
          end
        end
      end)
      return
    end

    uv.fs_open(filepath, "r", 438, function(err, fd)
      if err or not fd then
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
        return
      end

      local bytes_to_read = math.min(stat.size, 65536)
      uv.fs_read(fd, bytes_to_read, 0, function(read_err, data)
        uv.fs_close(fd, function() end)
        if read_err or not data then
          previewers.buffer_previewer_maker(filepath, bufnr, opts)
          return
        end

        -- 1. Check for binary files (null byte)
        if data:find("\0", 1, true) then
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              if opts.winid and vim.api.nvim_win_is_valid(opts.winid) then
                putils.set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
              else
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Binary cannot be previewed" })
              end
            end
          end)
          return
        end

        -- 2. Check for lines exceeding MAX_LINE_LENGTH
        for line in data:gmatch("[^\r\n]+") do
          if #line > MAX_LINE_LENGTH then
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(bufnr) then
                local msg = string.format("File has long lines (>%d chars); preview skipped", MAX_LINE_LENGTH)
                if opts.winid and vim.api.nvim_win_is_valid(opts.winid) then
                  putils.set_preview_message(bufnr, opts.winid, msg)
                else
                  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { msg })
                end
              end
            end)
            return
          end
        end

        vim.schedule(function()
          previewers.buffer_previewer_maker(filepath, bufnr, opts)
        end)
      end)
    end)
  end)
end

require('telescope').setup{
  defaults = {
    sorting_strategy = 'ascending',
    layout_config = {
      prompt_position = 'top',
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--max-columns=500",
      "--max-columns-preview",
    },
    buffer_previewer_maker = custom_buffer_previewer_maker,
    preview = {
      filesize_limit = .5, -- size limit in MB
      timeout = 50,        -- Timeout in ms
      treesitter = false,  -- Don't use treesitter in preview pane (speed up preview)
    },
  },
  pickers = {
    live_grep = {
      -- Minified JS files and similar files with incredibly long lines freeze Telescope
      file_ignore_patterns = {
        '%.ipynb',
        '%.html', '%.js', '%.min.js', '%.min.css',
        '%.jpeg', '%.jpg', '%.svg', '%.png', '%.jar',
        '^.git', '^css/', '^cesium/', '^node_modules/',
        '%.lock', '%.crt', '^docs/site/'
      },
      no_ignore = not use_gitignore,
      hidden = show_hidden,
      additional_args = function(_)
        if should_show_hidden(vim.loop.cwd()) then
          return { "--hidden" }
        else
          return {}
        end
      end,
    },
    find_files = {
      file_ignore_patterns = { '.git/', '%.ipynb' },
      hidden = show_hidden,
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                     -- false will only do exact matching
      override_generic_sorter = true,   -- override the generic sorter
      override_file_sorter = true,      -- override the file sorter
      case_mode = "smart_case",         -- or "ignore_case" or "respect_case"
                                        -- the default case_mode is "smart_case"
      file_ignore_patterns = { '%.ipynb', '%.html', '%.js', '%.min.js', '%.min.css', '^css/', '^cesium/' }, -- Minified JS files cause 5+ seconds of lag
    }
  }
}
require('telescope').load_extension('fzf')

-- [g]oto[r]eferences
vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, { noremap = true, silent = true })
-- [g]oto[d]efinition
vim.keymap.set('n', 'gd', function() require('telescope.builtin').lsp_definitions() end, { noremap = true, silent = true })
