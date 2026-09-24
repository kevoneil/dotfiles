local lspconfig = require('lspconfig')

lspconfig.gdscript.setup({
  -- Force Neovim to connect to Godot's built-in server port
  cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
  
  -- Ensure it attaches even if you open a file from outside the project directory
  root_dir = lspconfig.util.root_pattern("project.godot", ".git"),
})

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Ensure the native tsgo language server environment is explicitly recognized
      vtsls = {
        settings = {
          typescript = {
            experimental = {
              -- Toggles native tsgo integration if using upstream bridge layers
              useTsgo = true,
            },
          },
        },
      },
    },
  },
}
