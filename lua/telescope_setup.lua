require('telescope').setup{
  defaults = {
    sorting_strategy = 'ascending',
    layout_config = {
      prompt_position = 'top',
    },
  },
  pickers = {
    live_grep = {
      file_ignore_patterns = { '%.html', '%.js' }, -- Minified JS files cause 5+ seconds of lag
      -- no_ignore = true, -- ignore .gitignore
    }
  },
  preview = {
    filesize_limit = .5, -- size limit in MB
    timeout = 250,       -- Timeout in ms
    treesitter = false,  -- Don't uses treesitter in preview pane (speed up preview)
  },
  extensions = {
    fzf = {
      fuzzy = true,                     -- false will only do exact matching
      override_generic_sorter = true,   -- override the generic sorter
      override_file_sorter = true,      -- override the file sorter
      case_mode = "smart_case",         -- or "ignore_case" or "respect_case"
                                        -- the default case_mode is "smart_case"
      file_ignore_patterns = { "%.html", "%.js" }, -- Minified JS files cause 5+ seconds of lag
    }
  }
}
require('telescope').load_extension('fzf')

-- [g]oto[r]eferences
vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, { noremap = true, silent = true })
-- [g]oto[d]efinition
vim.keymap.set('n', 'gd', function() require('telescope.builtin').lsp_definitions() end, { noremap = true, silent = true })
