cask_args appdir: "/Applications"

# Browsers
unless ENV["HOMEBREW_DOTFILES_SKIP_BROWSERS"] == "1"
  cask "google-chrome"
  cask "firefox"
end

# Communication and knowledge
unless ENV["HOMEBREW_DOTFILES_SKIP_COMMUNICATION_KNOWLEDGE"] == "1"
  cask "zoom"
  cask "obsidian"
  cask "slack"
end

# Security and networking
unless ENV["HOMEBREW_DOTFILES_SKIP_SECURITY_NETWORKING"] == "1"
  cask "1password"
  cask "outline-manager"
end

# Terminal and editor
cask "ghostty"
cask "visual-studio-code"
cask "font-jetbrains-mono-nerd-font"

# Shell and terminal workflow
brew "starship"
brew "mise"
brew "herdr"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# Version control
brew "git"
brew "gh"
brew "tig"
brew "lazygit"

# Modern command-line essentials
brew "eza"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "jq"
brew "tree"

# Neovim and LazyVim requirements
brew "neovim"
brew "tree-sitter-cli"

# Coding agents managed by Homebrew
unless ENV["HOMEBREW_DOTFILES_SKIP_AGENTS"] == "1"
  tap "anomalyco/tap"
  cask "claude-code"
  cask "codex"
  brew "anomalyco/tap/opencode"
end
