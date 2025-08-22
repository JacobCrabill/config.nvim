-- Enable Lua / NeoVim API support
require('neodev').setup({})

-- Setup lspconfig
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require('lspconfig')
local lsp_configs = require("lspconfig.configs")

local cwd = vim.loop.cwd()
local project_blacklist = { } -- '/home/jcrabill/Codes/px4-firmware' }

local compile_commands_dir = {
  ["/home/jcrabill/Codes/px4-firmware"] = "./build/px4_sitl_jsbsim",
  ["/home/jcrabill/Codes/darkhive-autonomy"] = "./build-x86/darkhive-autonomy/build",
}

local is_blacklisted = function(dir)
  for _, project in ipairs(project_blacklist) do
    if string.find(dir, project) or dir == project then
      -- vim.notify("LSP: Ignoring blacklisted project: " .. dir, vim.log.levels.DEBUG)
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
      -- preference = { 'clangd', 'zls', 'pylsp', 'csharp_ls' },
      preference = { 'ccls', 'zls', 'pylsp', 'csharp_ls', 'superhtml' },
    },
}

----------------------------------------------------------------
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled
----------------------------------------------------------------

-- Generic Language Server on_attach function
local lsp_on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, nil)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, nil)
  vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, nil)
  if client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)
  end
  -- Optional: Turn off semantic tokens overriding our current highlighting
  -- See: https://github.com/neovim/neovim/pull/21100
  -- client.server_capabilities.semanticTokensProvider = nil
end

--- C++ Language Server (clangd)
if not is_blacklisted(cwd) then
  if cwd == nil then
    return
  end
  -- lspconfig.clangd.setup {
  --   capabilities = capabilities,
  --   cmd = { "clangd", "--background-index=0", "--header-insertion=never"},
  --   on_attach = lsp_on_attach,
  -- }
  -- TODO: Telescope picker for 'compilationDatabaseDirectory' to allow changing PX4 targets
  if compile_commands_dir[cwd] == nil then
    compile_commands_dir[cwd] = "./build/"
  end
  lspconfig.ccls.setup {
    capabilities = capabilities,
    cmd = { "ccls" },
    init_options = {
      compilationDatabaseDirectory = compile_commands_dir[cwd]
    },
    on_attach = lsp_on_attach,
  }
end

-- Zig Language Server (ZLS)
lspconfig.zls.setup {
  capabilities = capabilities,
  on_attach = lsp_on_attach,
}

-- Python Language Server (pylsp)
lspconfig.pylsp.setup {
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
          ignore = {'E501', 'E231'},
          maxLineLength = 120,
        },
      },
    },
  },
}

-- Lua language support (including NeoVim APIs)
lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace"
      }
    }
  }
})

-- lspconfig.superhtml.setup({
--   cmd = { "superhtml", "lsp" },
--   capabilities = capabilities,
--   on_attach = lsp_on_attach,
-- })
vim.api.nvim_create_autocmd("Filetype", {
pattern = { "html", "shtml", "htm" },
callback = function()
  vim.lsp.start({
    name = "superhtml",
    cmd = { "superhtml", "lsp" },
    root_dir = vim.fs.dirname(vim.fs.find({".git"}, { upward = true })[1])
  })
end
})

-- (For Foxglove) TypeScript LSP
-- lspconfig.tsserver.setup({
--   capabilities = capabilities,
-- })
require("typescript-tools").setup({})

-- CMake LSP Setup
if not lsp_configs.neocmake then
    lsp_configs.neocmake = {
        default_config = {
            cmd = { "neocmakelsp", "--stdio" },
            filetypes = { "cmake" },
            root_dir = function(fname)
                return lspconfig.util.find_git_ancestor(fname)
            end,
            single_file_support = true,-- suggested
            on_attach = lsp_on_attach, -- Not actually clangd specific, so should work
            init_options = {
                format = {
                    enable = false
                },
                lint = {
                    enable = true
                },
                scan_cmake_in_package = true -- default is true
            }
        }
    }
    lspconfig.neocmake.setup({})
end

-- C# (Dotnet / Unity)
lspconfig.csharp_ls.setup {
  capabilities = capabilities,
  on_attach = lsp_on_attach,
}

----------------------------------------------------------------
-- Diagnostics Setup
----------------------------------------------------------------

vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        -- Use a function to dynamically turn signs off
        -- and on, using buffer local variables
        signs = true,

        -- Enable/Disable underline squiggles
        underline = true,

        -- Enable virtual text, override spacing to 4
        -- virtual_text = {spacing = 4},
        virtual_text = true,

        -- Diable showing of diagnostics in insert mode
        update_in_insert = false
    })

-- Open the LSP hover menu showing documentation of the symbol under the cursor
vim.keymap.set('n', 'K', vim.lsp.buf.hover, nil)

-- Turn off diagnostics for the current buffer
vim.api.nvim_create_user_command('DisableDiagnostics', function() vim.diagnostics.disable() end, {})
