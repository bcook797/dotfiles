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
