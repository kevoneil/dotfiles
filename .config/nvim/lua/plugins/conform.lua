return {
  "stevearc/conform.nvim",
  opts = {
    -- Map file types to formatters
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
    },
  },
  keys = {
    -- Create your manual keymap using LazyVim's native keys handler
    {
      "<leader>mp",
      function()
        require("conform").format({ lsp_format = "fallback", async = false })
      end,
      mode = { "n", "v" },
      desc = "Format file with Prettier",
    },
  },
}
