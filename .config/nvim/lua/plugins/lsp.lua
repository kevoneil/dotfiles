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
