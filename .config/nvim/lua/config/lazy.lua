-- MANAGED_BY_DOTFILES_INSTALL_SH: this marker lets install.sh detect that
-- ~/.config/nvim is already wired up to this repo, so it can skip the
-- destructive backup+reclone step on re-runs.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Point plugin spec search at this dotfiles repo's nvim folder instead of a
-- copy under ~/.config/nvim/lua/plugins. Adding it to the runtimepath lets
-- `{ import = "plugins" }` below resolve lua/plugins/*.lua straight from the
-- dotfiles checkout, so edits there take effect without re-copying/restarting
-- install.sh.
--
-- The path is derived from $HOME at runtime (not baked in as an absolute,
-- user-specific string) plus a relative suffix substituted by install.sh at
-- setup time — e.g. "dotfiles/.config/nvim" if the repo lives at
-- ~/dotfiles. This way the generated file works for whichever user actually
-- runs it, instead of hardcoding the username of whoever ran install.sh.
local dotfiles_nvim_relative = "__DOTFILES_NVIM_RELATIVE__"
local home = os.getenv("HOME") or ""
local dotfiles_nvim = (home ~= "" and dotfiles_nvim_relative ~= "") and (home .. "/" .. dotfiles_nvim_relative) or ""
if dotfiles_nvim ~= "" and (vim.uv or vim.loop).fs_stat(dotfiles_nvim) then
  vim.opt.rtp:prepend(dotfiles_nvim)
end

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins (resolved from dotfiles_nvim above)
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- lazy.nvim resets the runtimepath to just $VIMRUNTIME + your config
      -- dir for faster startup, which would otherwise drop dotfiles_nvim
      -- (and its lua/plugins specs) that we prepended above.
      paths = dotfiles_nvim ~= "" and { dotfiles_nvim } or {},
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
