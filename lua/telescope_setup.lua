require('telescope').setup{
  defaults = {
    sorting_strategy = 'ascending',
    layout_config = {
      prompt_position = 'top',
    },
  },
  -- pickers = {
  --   find_files = {
  --     no_ignore = true, -- ignore .gitignore
  --   }
  -- },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
require('telescope').load_extension('fzf')

-- [G]oto[R]eferences
vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, { noremap = true, silent = true })
-- [G]oto[D]efinition
vim.keymap.set('n', 'gd', function() require('telescope.builtin').lsp_definitions() end, { noremap = true, silent = true })
