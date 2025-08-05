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

require('telescope').setup{
  defaults = {
    sorting_strategy = 'ascending',
    layout_config = {
      prompt_position = 'top',
    },
  },
  pickers = {
    live_grep = {
      file_ignore_patterns = { '%.html', '%.js', '.git', '%.min.js', '%.min.css', '^css/', '^cesium/' }, -- Minified JS files cause 5+ seconds of lag
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
      file_ignore_patterns = { '.git' },
      hidden = show_hidden,
    },
  },
  preview = {
    filesize_limit = .5, -- size limit in MB
    timeout = 50,       -- Timeout in ms
    treesitter = false,  -- Don't uses treesitter in preview pane (speed up preview)
  },
  extensions = {
    fzf = {
      fuzzy = true,                     -- false will only do exact matching
      override_generic_sorter = true,   -- override the generic sorter
      override_file_sorter = true,      -- override the file sorter
      case_mode = "smart_case",         -- or "ignore_case" or "respect_case"
                                        -- the default case_mode is "smart_case"
      file_ignore_patterns = { '%.html', '%.js', '%.min.js', '%.min.css', '^css/', '^cesium/' }, -- Minified JS files cause 5+ seconds of lag
    }
  }
}
require('telescope').load_extension('fzf')

-- [g]oto[r]eferences
vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, { noremap = true, silent = true })
-- [g]oto[d]efinition
vim.keymap.set('n', 'gd', function() require('telescope.builtin').lsp_definitions() end, { noremap = true, silent = true })
