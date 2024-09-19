-- Enable Lua / NeoVim API support
require('neodev').setup({})

-- Setup lspconfig
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require('lspconfig')
local lsp_configs = require("lspconfig.configs")

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
    highlight = false,
    separator = " > ",
    depth_limit = 0,
    depth_limit_indicator = "..",
    lsp = {
      auto_attach = true,
      preference = { 'clangd', 'zls', 'pylsp' },
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
lspconfig.clangd.setup {
  capabilities = capabilities,
  cmd = { "clangd-12", "--background-index", "--header-insertion=never"},
  on_attach = lsp_on_attach,
}

-- Zig Language Server (ZLS)
lspconfig.zls.setup {
  capabilities = capabilities,
  on_attach = lsp_on_attach,
}

-- Python Language Server (pylsp)
lspconfig.pylsp.setup {
  capabilities = capabilities,
  on_attach = lsp_on_attach,
}

-- Rust language support setup
local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})

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
