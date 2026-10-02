-- GDScript support for the Godot game engine.
--
-- Godot doesn't ship a standalone LSP binary — the running Godot editor
-- itself exposes an LSP server over TCP (port 6005 by default). So there's
-- nothing for Mason to install here; we just need:
--   1. A treesitter parser so GDScript gets proper syntax highlighting.
--   2. An nvim-lspconfig `gdscript` entry that connects to the editor's
--      built-in LSP via TCP instead of spawning a command.
--
-- NOTE: This does not install the Godot editor itself — install.sh
-- intentionally does not install Godot, since it's a large GUI application
-- and not something every user of this dotfiles repo wants. Install it
-- yourself (e.g. `brew install --cask godot`) if you need it.
--
-- To use it: open your project in the Godot editor (Editor > Editor
-- Settings > Network > Language Server must be enabled, which it is by
-- default), then edit .gd files in nvim with that project open.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "gdscript", "godot_resource" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gdscript = {
          -- lspconfig's default gdscript config already connects over TCP
          -- to 127.0.0.1:6005; this just ensures it's enabled.
        },
      },
    },
  },
}
