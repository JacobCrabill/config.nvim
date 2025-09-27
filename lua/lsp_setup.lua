-- Enable Lua / NeoVim API support
require('lazydev').setup()

-- Setup lspconfig
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local cpp_lsp = 'ccls' -- ccls or clangd

local cwd = vim.loop.cwd()
local project_blacklist = {
  -- '/home/jcrabill/Codes/px4-firmware'
}

local compile_commands_dir = {
  ["/home/jcrabill/Codes/px4-firmware"] = "./build/ark_fmu-v6_default",
  -- ["/home/jcrabill/Codes/px4-firmware"] = "./build/px4_sitl_jsbsim",
  -- ["/home/jcrabill/Codes/darkhive-autonomy"] = "./build-x86/darkhive-autonomy/build",
}

local is_blacklisted = function(dir)
  for _, project in ipairs(project_blacklist) do
    if string.find(dir, project) or dir == project then
      vim.notify("LSP: Ignoring blacklisted project: " .. dir, vim.log.levels.INFO)
      -- vim.api.nvim_echo("LSP: Ignoring blacklisted project: " .. dir, false, {})
      return true
    end
  end
  return false
end

local navic = require("nvim-navic")
navic.setup {
    icons = {
        File          = "󰈙 ",
        Module        = " ",
        Namespace     = "󰌗 ",
        Package       = " ",
        Class         = "󰌗 ",
        Method        = "󰆧 ",
        Property      = " ",
        Field         = " ",
        Constructor   = " ",
        Enum          = "󰕘",
        Interface     = "󰕘",
        Function      = "󰊕 ",
        Variable      = "󰆧 ",
        Constant      = "󰏿 ",
        String        = " ",
        Number        = "󰎠 ",
        Boolean       = "◩ ",
        Array         = "󰅪 ",
        Object        = "󰅩 ",
        Key           = "󰌋 ",
        Null          = "󰟢 ",
        EnumMember    = " ",
        Struct        = "󰌗 ",
        Event         = " ",
        Operator      = "󰆕 ",
        TypeParameter = "󰊄 ",
    },
    highlight = true,
    separator = " > ",
    depth_limit = 0,
    depth_limit_indicator = "..",
    lsp = {
      auto_attach = not is_blacklisted(cwd),
      preference = { cpp_lsp, 'zls', 'neocmake', 'pylsp', 'lua_ls', 'superhtml', 'csharp_ls', 'kotlin_language_server' },
    },
}

----------------------------------------------------------------
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled
----------------------------------------------------------------

-- Enable all language servers by default
vim.lsp.enable({ cpp_lsp, 'zls', 'neocmake', 'pylsp', 'lua_ls', 'superhtml', 'csharp_ls', 'kotlin_language_server' })

-- Generic Language Server on_attach function
local lsp_on_attach = function(client, bufnr)
  -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', {
    scope = 'local',
    buf = bufnr,
  })
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, nil)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, nil)
  vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, nil)
  vim.keymap.set("n", "gl", vim.diagnostic.open_float, nil)
  if client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)
  end
  -- Optional: Turn off semantic tokens overriding our current highlighting
  -- See: https://github.com/neovim/neovim/pull/21100
  -- client.server_capabilities.semanticTokensProvider = nil
end

--- C++ Language Server (clangd or ccls)
if not is_blacklisted(cwd) then
  assert(cwd ~= nil, "cwd is nil!")

  if cpp_lsp == 'clangd' then
    vim.lsp.config('clangd', {
      capabilities = capabilities,
      cmd = { "clangd", "--background-index=0", "--header-insertion=never" },
      on_attach = lsp_on_attach,
      settings = {
        Lua = {
            format = {
            enable = true,
            defaultConfig = {
              indent_style = "space",
              indent_size = "2",
            },
          },
        }
      }
    })
  elseif cpp_lsp == 'ccls' then
    -- TODO: Telescope picker for 'compilationDatabaseDirectory' to allow changing PX4 targets
    if compile_commands_dir[cwd] == nil then
      compile_commands_dir[cwd] = "./build/"
    end
    vim.lsp.config('ccls', {
      capabilities = capabilities,
      on_attach = lsp_on_attach,
      cmd = { "ccls" },
      init_options = {
        compilationDatabaseDirectory = compile_commands_dir[cwd]
      },
    })
  end
end

-- Zig Language Server (ZLS)
vim.lsp.config('zls', {
  capabilities = capabilities,
  on_attach = lsp_on_attach,
})

-- Auto-fix minor issues on save (e.g. unused variables)
vim.api.nvim_create_autocmd('BufWritePre',{
  pattern = {"*.zig", "*.zon"},
  callback = function(ev)
    vim.lsp.buf.code_action({
      context = { only = { "source.fixAll" } },
      apply = true,
    })
  end
})

-- Python Language Server (pylsp)
vim.lsp.config('pylsp', {
  capabilities = capabilities,
  on_attach = lsp_on_attach,
  settings = {
    pylsp = {
      plugins = {
        black = { enabled = true },
        pylint = { enabled = false },
        pyflakes = { enabled = false },
        pycodestyle = {
          enabled = true,
          ignore = {'E501', 'E231', 'E201', 'E202', 'E203', 'W605', 'W503'},
          maxLineLength = 120,
        },
      },
    },
  },
})

-- Lua language support (including NeoVim APIs)
vim.lsp.enable('lua_ls')
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace"
      }
    }
  }
})

-- SuperHTML - HTML LSP / Linter
vim.lsp.enable('superhtml')

vim.lsp.enable('neocmake')
vim.lsp.config('neocmake', {
  -- on_attach = lsp_on_attach,
})

-- -- CMake LSP Setup
-- if not lsp_configs.neocmake then
--     lsp_configs.neocmake = {
--         default_config = {
--             cmd = { "neocmakelsp", "--stdio" },
--             filetypes = { "cmake" },
--             root_dir = function(fname)
--                 return lspconfig.util.find_git_ancestor(fname)
--             end,
--             single_file_support = true,-- suggested
--             on_attach = lsp_on_attach, -- Not actually clangd specific, so should work
--             init_options = {
--                 format = {
--                     enable = false
--                 },
--                 lint = {
--                     enable = true
--                 },
--                 scan_cmake_in_package = true -- default is true
--             }
--         }
--     }
--     lspconfig.neocmake.setup({})
-- end

-- C# (Dotnet / Unity)
vim.lsp.enable('csharp_ls')
vim.lsp.config('csharp_ls', {
  capabilities = capabilities,
  on_attach = lsp_on_attach,
})

-- Kotlin (Java)
vim.lsp.enable('kotlin_language_server')
vim.lsp.config('kotlin_language_server', {
  capabilities = capabilities,
  on_attach = lsp_on_attach,
})

-- (For Foxglove) TypeScript LSP
-- vim.lsp.enable('tsserver', {
--   capabilities = capabilities,
-- })
-- require("typescript-tools").setup({})

----------------------------------------------------------------
-- Diagnostics Setup
----------------------------------------------------------------

-- TODO: Update for latest neovim APIs
-- vim.lsp.handlers["textDocument/publishDiagnostics"] =
--     vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
--         -- Use a function to dynamically turn signs off
--         -- and on, using buffer local variables
--         signs = true,
--
--         -- Enable/Disable underline squiggles
--         underline = true,
--
--         -- Enable virtual text, override spacing to 4
--         -- virtual_text = {spacing = 4},
--         virtual_text = true,
--         virtual_lines = true,
--
--         -- Diable showing of diagnostics in insert mode
--         update_in_insert = false
--     })

-- Open the LSP hover menu showing documentation of the symbol under the cursor
vim.keymap.set('n', 'K', vim.lsp.buf.hover, nil)
-- Open the LSP hover menu showing any active diagnostics under the cursor
vim.keymap.set('n', 'L', vim.diagnostic.open_float, nil)

-- Turn diagnostics off/on for the current buffer
vim.api.nvim_create_user_command('DisableDiagnostics', function() vim.diagnostics.disable() end, {})
vim.api.nvim_create_user_command('EnableDiagnostics', function() vim.diagnostics.enable() end, {})
