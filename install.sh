#!/bin/bash

# Exit immediately if a command exits with a non-zero status,
# treat unset variables as errors, and fail pipelines on any stage error
set -euo pipefail

# Resolve the directory this script lives in, so plugin files can be
# copied regardless of where the dotfiles repo is checked out.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Refuse to run as root/sudo: Homebrew explicitly refuses to install or run
# as root ("Running Homebrew as root is extremely dangerous and no longer
# supported"), and installing Oh My Zsh / dotfiles as root would scatter
# files owned by root into what should be your own home directory. This
# script requests sudo itself (via `sudo -v` below) only for the one step
# that actually needs it, so it should always be invoked as your normal user.
if [ "$EUID" -eq 0 ]; then
  echo "❌ Please do not run this script with sudo or as root."
  echo "   Run it as your normal user instead: ./install.sh"
  echo "   It will prompt for your password only when elevated privileges are needed."
  exit 1
fi

echo "=========================================="
echo " Starting Full macOS Dev Environment Setup"
echo "=========================================="

# 1. Request sudo privileges upfront
echo "🔑 Please enter your password to authorize the installation:"
sudo -v

# Keep-alive: update existing sudo time stamp until the script finishes
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

# 2. Install Xcode Command Line Tools if missing
if ! xcode-select -p &>/dev/null; then
  echo "🛠️ Installing Xcode Command Line Tools..."
  xcode-select --install

  echo "⏳ Waiting for Xcode Command Line Tools to finish installing..."
  CLT_WAIT_SECONDS=0
  CLT_WAIT_TIMEOUT=1800 # 30 minutes
  until xcode-select -p &>/dev/null; do
    if [ "$CLT_WAIT_SECONDS" -ge "$CLT_WAIT_TIMEOUT" ]; then
      echo "❌ Timed out waiting for Xcode Command Line Tools to install after $((CLT_WAIT_TIMEOUT / 60)) minutes."
      echo "   Please complete the installation manually, then re-run this script."
      exit 1
    fi
    sleep 5
    CLT_WAIT_SECONDS=$((CLT_WAIT_SECONDS + 5))
  done
  echo "✅ Xcode Command Line Tools installation detected."
else
  echo "✅ Xcode Command Line Tools are already installed."
fi

# 3. Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Configure Homebrew path based on Apple Silicon (ARM) vs Intel (x86_64)
  UNAME_M=$(uname -m)
  if [ "$UNAME_M" = "arm64" ]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >>"$HOME/.zprofile"
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "✅ Homebrew installed and configured successfully."
else
  echo "✅ Homebrew is already installed."
fi

# 4. Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🦁 Installing Oh My Zsh..."
  # RUNZSH=no prevents the installer from dropping you into a new zsh session mid-script
  KEEP_ZSHRC=yes RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "✅ Oh My Zsh installed successfully."
else
  echo "✅ Oh My Zsh is already installed."
fi

# 5. Install Neovim & Dependencies
echo "🍺 Updating Homebrew..."
brew update

echo "⚡ Installing Neovim and foundational dependencies..."
# ripgrep, fd, and git are required for LazyVim's telescope fuzzy finding
# lazygit: terminal UI for git, yazi: terminal file manager, nvm: Node version manager
brew install neovim ripgrep fd git lazygit yazi nvm

# nvm (installed via Homebrew) isn't auto-wired into the shell like other
# formulae — it needs NVM_DIR set and nvm.sh sourced manually.
NVM_BREW_PREFIX="$(brew --prefix nvm)"
if ! grep -q 'NVM_DIR' "$HOME/.zprofile" 2>/dev/null; then
  {
    echo 'export NVM_DIR="$HOME/.nvm"'
    echo "[ -s \"$NVM_BREW_PREFIX/nvm.sh\" ] && \\. \"$NVM_BREW_PREFIX/nvm.sh\""
  } >>"$HOME/.zprofile"
  echo "✅ nvm shell setup added to ~/.zprofile."
else
  echo "✅ nvm shell setup already present in ~/.zprofile."
fi
mkdir -p "$HOME/.nvm"

# 6. Install LazyVim Starter Template
#
# Safety: if ~/.config/nvim is already managed by this script (it contains
# our MANAGED_BY_DOTFILES_INSTALL_SH marker), skip the backup+reclone
# entirely — there's nothing destructive to do, it's already wired up.
# Only back up and re-clone when nvim is missing or belongs to some other,
# unmanaged config, and timestamp backups so re-runs never clobber a
# previous backup.
if [ -f "$HOME/.config/nvim/lua/config/lazy.lua" ] && grep -q "MANAGED_BY_DOTFILES_INSTALL_SH" "$HOME/.config/nvim/lua/config/lazy.lua"; then
  echo "✅ ~/.config/nvim is already managed by this script. Skipping backup/reclone."
elif [ ! -d "$HOME/.config/nvim" ]; then
  echo "🚀 Installing LazyVim starter template..."
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  # Remove the .git folder so you can start your own git tracking later
  rm -rf "$HOME/.config/nvim/.git"
  echo "✅ LazyVim files cloned to ~/.config/nvim"
else
  BACKUP_SUFFIX="bak.$(date +%Y%m%d%H%M%S)"
  echo "⚠️  ~/.config/nvim already exists and isn't managed by this script."
  echo "   Backing it up to *.${BACKUP_SUFFIX} before installing LazyVim..."

  mv "$HOME/.config/nvim" "$HOME/.config/nvim.${BACKUP_SUFFIX}" || true
  [ -d "$HOME/.local/share/nvim" ] && mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.${BACKUP_SUFFIX}"
  [ -d "$HOME/.local/state/nvim" ] && mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.${BACKUP_SUFFIX}"
  [ -d "$HOME/.cache/nvim" ] && mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.${BACKUP_SUFFIX}"

  echo "🚀 Installing LazyVim starter template..."
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
  echo "✅ Previous config backed up to *.${BACKUP_SUFFIX} and LazyVim installed."
fi

# 7. Point LazyVim's plugin search directly at this repo's plugins folder
# instead of copying files, so edits in the dotfiles checkout take effect
# immediately without re-running this script.
echo "🔌 Wiring LazyVim's plugin search to $SCRIPT_DIR/.config/nvim/lua/plugins..."
mkdir -p "$HOME/.config/nvim/lua/config"

# Store the dotfiles path relative to $HOME (not the full absolute path),
# so the generated lazy.lua resolves it via $HOME at runtime instead of
# baking in the username of whoever ran this install script.
if [[ "$SCRIPT_DIR" == "$HOME"/* ]]; then
  DOTFILES_NVIM_RELATIVE="${SCRIPT_DIR#"$HOME"/}/.config/nvim"
else
  echo "⚠️  Dotfiles repo is not under \$HOME ($SCRIPT_DIR); LazyVim plugin import may not resolve correctly for other users on this machine."
  DOTFILES_NVIM_RELATIVE=""
fi

sed "s|__DOTFILES_NVIM_RELATIVE__|$DOTFILES_NVIM_RELATIVE|g" \
  "$SCRIPT_DIR/.config/nvim/lua/config/lazy.lua" >"$HOME/.config/nvim/lua/config/lazy.lua"
echo "✅ LazyVim config now imports plugins from the dotfiles repo."

echo "=========================================="
echo "🎉 Setup complete! Please restart your terminal."
echo "💡 To finish plugin installation, simply run the command: nvim"
echo "=========================================="
