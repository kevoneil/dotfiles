return {
  "rmagatti/goto-preview",
  dependencies = {
    "rmagatti/logger.nvim",
    "nvim-telescope/telescope.nvim", -- ADDED THIS LINE
  },
  event = "BufEnter",
  config = function()
    require("goto-preview").setup({
      width = 120,
      height = 15,
      border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" },
      default_mappings = true,
      debug = false,
      opacity = nil,
      resizing_mappings = false,
      post_open_hook = nil,
      post_close_hook = nil,
      references = {
        provider = "telescope",
        telescope = require("telescope.themes").get_dropdown({ hide_preview = false }),
      },
      focus_on_open = true,
      dismiss_on_move = false,
      force_close = true,
      bufhidden = "wipe",
      stack_floating_preview_windows = true,
      same_file_float_preview = true,
      preview_window_title = { enable = true, position = "left" },
      zindex = 1,
      vim_ui_input = true,
    })
  end,
}
