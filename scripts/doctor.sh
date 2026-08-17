#!/usr/bin/env bash

set -u

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0
warnings=0

pass() { printf 'PASS  %s\n' "$*"; }
warn() { printf 'WARN  %s\n' "$*"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL  %s\n' "$*"; failures=$((failures + 1)); }

check_link() {
  local source="$1"
  local target="$2"
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    pass "${target} -> ${source}"
  elif [[ -e "$target" || -L "$target" ]]; then
    warn "${target} exists but is not linked to this repository"
  else
    fail "${target} is missing"
  fi
}

version_line() {
  local name="$1"
  local executable="$2"
  shift 2
  if command -v "$executable" >/dev/null 2>&1; then
    local path version source
    path="$(command -v "$executable")"
    version="$("$executable" "$@" 2>&1 | head -n 1)"
    case "$path" in
      /opt/homebrew/*|/usr/local/*) source="Homebrew or system package" ;;
      "${HOME}/.local"/*) source="native user install" ;;
      *) source="other" ;;
    esac
    pass "${name}: ${version} (${path}; ${source})"
  else
    fail "${name} executable not found"
  fi
}

printf 'Dotfiles doctor\n=================\n'

if command -v brew >/dev/null 2>&1; then
  if brew bundle check --file "${REPO_DIR}/Brewfile" >/dev/null 2>&1; then
    pass "Homebrew bundle is satisfied"
  else
    fail "Homebrew bundle has missing dependencies"
  fi
  brew doctor >/dev/null 2>&1 && pass "brew doctor" || warn "brew doctor reported warnings"
else
  fail "Homebrew is not available"
fi

check_link "${REPO_DIR}/.zprofile" "${HOME}/.zprofile"
check_link "${REPO_DIR}/.zshrc" "${HOME}/.zshrc"
check_link "${REPO_DIR}/config/ghostty/config" "${HOME}/Library/Application Support/com.mitchellh.ghostty/config"
check_link "${REPO_DIR}/.gitconfig" "${HOME}/.gitconfig"

if [[ -f "${HOME}/.config/nvim/lua/config/lazy.lua" && ! -d "${HOME}/.config/nvim/.git" ]]; then
  pass "LazyVim starter is installed"
else
  fail "LazyVim starter is missing or still contains its Git metadata"
fi

check_link "${REPO_DIR}/agents/AGENTS.md" "${HOME}/.codex/AGENTS.md"
check_link "${REPO_DIR}/agents/AGENTS.md" "${HOME}/.pi/agent/AGENTS.md"
check_link "${REPO_DIR}/agents/AGENTS.md" "${HOME}/.config/opencode/AGENTS.md"
check_link "${REPO_DIR}/agents/AGENTS.md" "${HOME}/.claude/CLAUDE.md"

zsh -n "${REPO_DIR}/.zprofile" "${REPO_DIR}/.zshrc" \
  && pass "Zsh configuration syntax" \
  || fail "Zsh configuration syntax"

if command -v starship >/dev/null 2>&1; then
  if [[ -f "${HOME}/.config/starship.toml" ]]; then
    STARSHIP_CONFIG="${HOME}/.config/starship.toml" starship prompt >/dev/null 2>&1 \
      && pass "Starship Catppuccin Powerline configuration" \
      || fail "Starship configuration"
  else
    fail "Starship configuration is missing"
  fi
fi

if command -v ghostty >/dev/null 2>&1; then
  ghostty +validate-config --config-file="${REPO_DIR}/config/ghostty/config" >/dev/null 2>&1 \
    && pass "Ghostty configuration" \
    || fail "Ghostty configuration"
fi

version_line "Neovim" nvim --version
for dependency in git tree-sitter lazygit fzf rg fd; do
  command -v "$dependency" >/dev/null 2>&1 \
    && pass "LazyVim dependency: ${dependency}" \
    || fail "LazyVim dependency missing: ${dependency}"
done

if [[ -d "${HOME}/.local/share/nvim/lazy/LazyVim" ]]; then
  pass "LazyVim plugins are installed"
else
  warn "LazyVim plugins have not been synchronized yet"
fi

version_line "Claude Code" claude --version
version_line "Codex" codex --version
version_line "OpenCode" opencode --version
version_line "Pi" pi --version

if command -v brew >/dev/null 2>&1; then
  for agent in pi; do
    if brew list --formula "$agent" >/dev/null 2>&1 || brew list --cask "$agent" >/dev/null 2>&1; then
      warn "${agent} is Homebrew-managed; the plan uses a native installer for this harness"
    fi
  done
fi

printf '\nAuthentication is intentionally manual: run gh auth login, then launch claude, codex, opencode, and pi.\n'
printf 'Result: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
((failures == 0))
