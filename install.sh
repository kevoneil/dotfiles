#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

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

# 2. Install Xcode Command Line Tools if missing
if ! xcode-select -p &>/dev/null; then
  echo "🛠️ Installing Xcode Command Line Tools..."
  xcode-select --install

  echo "⏳ Waiting for Xcode Command Line Tools to finish installing..."
  echo "Please complete the GUI prompt if it appeared, then press any key to continue."
  read -n 1 -s -r
else
  echo "✅ Xcode Command Line Tools are already installed."
fi

# 3. Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://githubusercontent.com)"

  # Configure Homebrew path based on Apple Silicon (ARM) vs Intel (x86_64)
  UNAME_M=$(uname -m)
  if [ "$UNAME_M" = "arm64" ]; then
    echo "eval \"$(/opt/homebrew/bin/brew shellenv)\"" >>"$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "eval \"$(/usr/local/bin/brew shellenv)\"" >>"$HOME/.zprofile"
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
  KEEP_ZSHRC=yes RUNZSH=no sh -c "$(curl -fsSL https://githubusercontent.com)"
  echo "✅ Oh My Zsh installed successfully."
else
  echo "✅ Oh My Zsh is already installed."
fi

# 5. Install Neovim & Dependencies
echo "⚡ Installing Neovim and foundational dependencies..."
# ripgrep, fd, and git are required for LazyVim's telescope fuzzy finding
brew install neovim ripgrep fd git

# 6. Install LazyVim Starter Template
if [ ! -d "$HOME/.config/nvim" ]; then
  echo "🚀 Installing LazyVim starter template..."
  git clone https://github.com "$HOME/.config/nvim"
  # Remove the .git folder so you can start your own git tracking later
  rm -rf "$HOME/.config/nvim/.git"
  echo "✅ LazyVim files cloned to ~/.config/nvim"
else
  echo "⚠️  ~/.config/nvim already exists. Backing it up before installing LazyVim..."

  # Move old config directories to a .bak suffix just in case
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak" || true
  mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak" || true
  mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.bak" || true
  mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.bak" || true

  echo "🚀 Installing LazyVim starter template..."
  git clone https://github.com "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
  echo "✅ Previous config backed up to *.bak and LazyVim installed."
fi

echo "=========================================="
echo "🎉 Setup complete! Please restart your terminal."
echo "💡 To finish plugin installation, simply run the command: nvim"
echo "=========================================="
