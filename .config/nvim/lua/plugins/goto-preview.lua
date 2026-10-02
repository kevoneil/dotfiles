return {
  "rmagatti/goto-preview",
  dependencies = {
    "rmagatti/logger.nvim",
    "nvim-telescope/telescope.nvim", -- ADDED THIS LINE
  },
  event = "BufEnter",
  config = true,
}
