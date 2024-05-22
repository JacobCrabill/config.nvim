-- Configure our Debug Adapter Protocol settings
local dap = require("dap")
local dapui = require("dapui")
local dap_utils = require("dap-utils")
local tel_actions_state = require("telescope.actions.state")
local tel_actions = require("telescope.actions")

-- Virtual text plugin - Evaluates locals as virtual text within the buffer
-- I'm not convinced this is useful for me; set 'enabled = false' to disable
-- require('nvim-dap-virtual-text').setup({ enabled = false, commented = true, })

-- The main DAP UI - See :help nvim-dap-ui for options
dapui.setup()

-- Enable Telescope as a configuration picker
-- We'll configure this below
local telescope = require('telescope')
telescope.load_extension('dap')

--------------------------------------------------------------------------------
-- Basic Setup
--------------------------------------------------------------------------------

-- Set the paths to the available debuggers
-- NOTE: Normal LLDB does NOT support DAP; instead, you must use 'lldb-vscode'
local lldb_bin = vim.env.HOME .. '/.local/bin/lldb-vscode'

-- NOTE: GDB MUST be built with DAP support
-- To do so, build a gdb version >= 14.0 and make sure to configure as:
--   $ ./configure --prefix=$HOME/.local/ --with-python=/usr/bin/python3
-- Be sure to install libgmp-dev, libmpfr-dev, and python3-dev before running ./configure
local gdb_bin = vim.env.HOME .. '/.local/bin/gdb'

dap_utils.setup({
  gdb_path = gdb_bin,
  lldb_path = lldb_bin,
  default_adapter = 'gdb'
})

-- Automatically open/close the DAP UI on session start/end
dap.listeners.before.attach.dapui_config = dapui.open
dap.listeners.before.launch.dapui_config = dapui.open
dap.listeners.before.event_terminated.dapui_config = dapui.close
dap.listeners.before.event_exited.dapui_config = dapui.close

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

-- Terminate the debug session and close DAP UI
local function terminate_session()
  dap.terminate()
  dapui.close()
end

-- Create a Zig + LLDB config
-- Start a DAP session using the output from the Telescope prompt buffer
local function start_zig_dap(prompt_bufnr)
  local cmd = tel_actions_state.get_selected_entry()[1]
  tel_actions.close(prompt_bufnr)
  dap.run(dap_utils.create_config("Custom Zig exe runner", 'lldb', cmd))
end

-- Launch a Telescope picker for binary files at <cwd>/build/bin
local function zig_picker()
  require("telescope.builtin").find_files({
    find_command = {'find', vim.fn.getcwd() .. '/zig-out/bin/', '-type', 'f', '-executable'},
    attach_mappings = function(_, map)
      map("n", "<cr>", start_zig_dap)
      map("i", "<cr>", start_zig_dap)
      return true
    end,
  })
end
-- Map the above to the ':DebugZig' user command
vim.api.nvim_create_user_command('DebugZig', zig_picker, {})

--------------------------------------------------------------------------
-- Keybindings & Customization
--------------------------------------------------------------------------

-- Configure our DAP-related keybindings
vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, {})
vim.keymap.set('n', '<leader>dc', dap.continue, {})
vim.keymap.set('n', '<leader>dt', terminate_session, {})
vim.keymap.set('n', '<leader>n', dap.step_over, {})
vim.keymap.set('n', '<leader>si', dap.step_into, {})
vim.keymap.set('n', '<leader>so', dap.step_out, {})
vim.keymap.set('n', '<F5>', dap.continue, {})
vim.keymap.set('n', '<F10>', dap.step_over, {})
vim.keymap.set('n', '<F11>', dap.step_into, {})
vim.keymap.set('n', '<F12>', dap.step_out, {})
vim.keymap.set('n', '<leader>dl', dap.run_last, {})
vim.keymap.set('n', '<leader>td', dap_utils.telescope_dap_configs, {})

-- Change the breakpoint marker to a big red circle instead of a 'B'
vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})

--------------------------------------------------------------------------
-- Setup Adapters (Debuggers which support the Debug Adapter Protocol)
--------------------------------------------------------------------------

-- Setup LLDB
dap.adapters.lldb = {
  type = 'executable',
  command = lldb_bin,
  name = 'lldb',
}

-- Setup GDB
dap.adapters.gdb = {
  type = "executable",
  command = gdb_bin,
  args = { "-i", "dap", "-iex", "set auto-load safe-path " .. vim.fn.getcwd() },
  name = 'gdb'
}

--------------------------------------------------------------------------
-- Configurations
--------------------------------------------------------------------------

-- Create a DAP Adapter config for GDB
-- Requires GDB >=14 for built-in DAP support
local function gdb_config(name, default_path)
  default_path = default_path or ''
  default_path = vim.fn.getcwd() .. '/' .. default_path
  return {
    name = name,
    type = 'gdb',
    request = 'launch',
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    -- Take the executable and args via input prompt
    program = dap_utils.prompt_for_binary(default_path),
    args = dap_utils.prompt_for_args,
  }
end

-- Create a DAP Adapter config for LLDB
local function lldb_config(name, default_path)
  default_path = default_path or ''
  default_path = vim.fn.getcwd() .. default_path
  return {
    name = name,
    type = 'lldb',
    request = 'launch',
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    -- Take the executable and args via input prompt
    -- The prompt defaults to the the input default_path relative to the cwd
    program = dap_utils.prompt_for_binary(default_path),
    args = dap_utils.prompt_for_args,
  }
end

-- Setup LLDB and GDB adapters for C++, C, and Zig
dap.configurations.cpp = {
  lldb_config("[CMake] C++ exe + Args", "build/bin/"),
  gdb_config("[CMake] C++ exe + Args", "build/bin/"),
}
dap.configurations.c = {
  lldb_config("[C] exe + Args"),
  gdb_config("[C] exe + Args"),
}
dap.configurations.zig = {
  lldb_config("[Zig] exe + Args", "zig-out/bin/"),
  gdb_config("[Zig] exe + Args", "zig-out/bin/")
}
