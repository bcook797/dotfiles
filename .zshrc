# Native Zsh configuration. Oh My Zsh is intentionally not used.

# Homebrew is installed in /opt/homebrew on Apple Silicon and /usr/local on Intel.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/bin" $path)
export PATH

# Let Claude Code apply its own targeted Homebrew upgrades in the background.
export CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1

export EDITOR="nvim"
export VISUAL="nvim"

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

autoload -Uz compinit
compinit

if command -v brew >/dev/null 2>&1; then
  brew_prefix="$(brew --prefix)"
  [[ -r "${brew_prefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "${brew_prefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Syntax highlighting must be sourced after all widgets and shell integrations.
if [[ -n "${brew_prefix:-}" && -r "${brew_prefix}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "${brew_prefix}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
