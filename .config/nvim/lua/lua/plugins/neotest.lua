return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "marilari88/neotest-vitest",
  },
  -- 1. Correct way to override or add keys in LazyVim
  keys = {
    {
      "<leader>tr",
      function()
        require("neotest").run.run()
      end,
      desc = "Run Nearest Test",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "Run Current File",
    },
    {
      "<leader>ts",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Toggle Test Summary",
    },
    {
      "<leader>to",
      function()
        require("neotest").output.open({ enter = true })
      end,
      desc = "Show Test Output",
    },
  },
  -- 2. Use 'opts' so LazyVim can safely merge your adapters and settings
  opts = function(_, opts)
    -- Ensure the adapters table exists before inserting into it
    opts.adapters = opts.adapters or {}
    table.insert(opts.adapters, require("neotest-vitest")({}))
    -- Merge your custom status, output, and summary configurations
    opts.status = {
      enabled = true,
      virtual_text = true,
      signs = true,
    }
    opts.output = {
      enabled = true,
      open_on_run = true,
    }
    opts.summary = {
      follow = true,
      enabled = true,
      animated = true,
      expand_errors = true,
    }
  end,
}
