#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_ROOT="${HOME}/.dotfiles-backup"
readonly BACKUP_DIR="${BACKUP_ROOT}/$(date +%Y%m%d-%H%M%S)-$$"

export PATH="${HOME}/.local/bin:${PATH}"

DRY_RUN=false
SKIP_AGENTS=false
REFRESH_AGENTS=false
SKIP_NVIM_SYNC=false
APPLY_MACOS_DEFAULTS=false
SETUP_GITHUB_SSH=false

usage() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Options:
  --dry-run          Show what would change without changing it
  --skip-agents      Do not install native-only coding-agent harnesses
  --refresh-agents   Re-run native-only installers when commands exist
  --skip-nvim-sync   Do not install/synchronize LazyVim plugins
  --github-ssh       Authenticate GitHub and configure an SSH key
  --macos-defaults   Run the opt-in macOS defaults scaffold
  -h, --help         Show this help
EOF
}

log() {
  printf '[dotfiles] %s\n' "$*"
}

run() {
  if $DRY_RUN; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

while (($#)); do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --skip-agents) SKIP_AGENTS=true ;;
    --refresh-agents) REFRESH_AGENTS=true ;;
    --skip-nvim-sync) SKIP_NVIM_SYNC=true ;;
    --github-ssh) SETUP_GITHUB_SSH=true ;;
    --macos-defaults) APPLY_MACOS_DEFAULTS=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'This bootstrap supports macOS only.\n' >&2
  exit 1
fi

ensure_command_line_tools() {
  if xcode-select -p >/dev/null 2>&1; then
    return
  fi

  if $DRY_RUN; then
    log "Command Line Tools would be requested"
    return
  fi

  xcode-select --install
  log "Finish the Command Line Tools installation, then rerun setup.sh."
  exit 2
}

ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew"
    if $DRY_RUN; then
      log "Would run the official Homebrew installer"
      return
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif ! $DRY_RUN; then
    printf 'Homebrew was installed but brew is not available.\n' >&2
    exit 1
  fi
}

backup_path() {
  local target="$1"
  local relative
  relative="${target#${HOME}/}"
  run mkdir -p "${BACKUP_DIR}/$(dirname "$relative")"
  run mv "$target" "${BACKUP_DIR}/${relative}"
  log "Backed up ${target} to ${BACKUP_DIR}/${relative}"
}

link_path() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    log "Link already correct: ${target}"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup_path "$target"
  fi

  run mkdir -p "$(dirname "$target")"
  run ln -s "$source" "$target"
}

configure_starship() {
  local target="${HOME}/.config/starship.toml"

  if [[ -f "$target" && ! -L "$target" ]]; then
    log "Existing Starship configuration preserved: ${target}"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup_path "$target"
  fi

  run mkdir -p "$(dirname "$target")"
  run starship preset catppuccin-powerline -o "$target"
}

install_lazyvim() {
  local target="${HOME}/.config/nvim"
  local path

  if [[ -d "$target" && ! -L "$target" && -f "${target}/lua/config/lazy.lua" ]]; then
    log "LazyVim starter already installed: ${target}"
    return
  fi

  # Follow LazyVim's recommended clean-install flow, preserving every existing
  # Neovim directory in this bootstrap's timestamped backup location.
  for path in \
    "$target" \
    "${HOME}/.local/share/nvim" \
    "${HOME}/.local/state/nvim" \
    "${HOME}/.cache/nvim"; do
    if [[ -e "$path" || -L "$path" ]]; then
      backup_path "$path"
    fi
  done

  run mkdir -p "$(dirname "$target")"
  run git clone https://github.com/LazyVim/starter "$target"
  run rm -rf "${target}/.git"
}

install_native_agent() {
  local name="$1"
  local executable="$2"
  local url="$3"
  local interpreter="$4"
  local installer
  shift 4

  if command -v "$executable" >/dev/null 2>&1 && ! $REFRESH_AGENTS; then
    log "${name} already available; use --refresh-agents to reinstall"
    return
  fi

  if $DRY_RUN; then
    log "Would install ${name} from ${url}"
    return
  fi

  installer="$(mktemp "${TMPDIR:-/tmp}/dotfiles-agent-installer.XXXXXX")"
  curl --proto '=https' --tlsv1.2 -fsSL "$url" -o "$installer"
  if ! "$interpreter" "$installer" "$@"; then
    rm -f "$installer"
    return 1
  fi
  rm -f "$installer"
}

configure_git_identity() {
  local local_config="${HOME}/.gitconfig.local"
  local name email scope scope_name scope_email scope_config index=1

  if $DRY_RUN; then
    log "Would prompt for default and directory-scoped Git identities"
    return
  fi

  if [[ -f "$local_config" ]] && git config --file "$local_config" --get user.name >/dev/null 2>&1; then
    log "Existing local Git identity preserved in ${local_config}"
    return
  fi

  if [[ ! -t 0 ]]; then
    if [[ -n "${DOTFILES_GIT_NAME:-}" && -n "${DOTFILES_GIT_EMAIL:-}" ]]; then
      git config --file "$local_config" user.name "$DOTFILES_GIT_NAME"
      git config --file "$local_config" user.email "$DOTFILES_GIT_EMAIL"
    else
      log "Non-interactive run: set DOTFILES_GIT_NAME and DOTFILES_GIT_EMAIL or configure Git later"
    fi
    return
  fi

  read -r -p "Default Git name (leave blank to skip): " name
  if [[ -n "$name" ]]; then
    read -r -p "Default Git email: " email
    git config --file "$local_config" user.name "$name"
    git config --file "$local_config" user.email "$email"
  fi

  while true; do
    read -r -p "Directory prefix for a scoped Git identity (leave blank when done): " scope
    [[ -z "$scope" ]] && break
    [[ "$scope" == */ ]] || scope="${scope}/"
    read -r -p "Git name for ${scope}: " scope_name
    read -r -p "Git email for ${scope}: " scope_email
    scope_config="${HOME}/.gitconfig-identity-${index}"
    git config --file "$scope_config" user.name "$scope_name"
    git config --file "$scope_config" user.email "$scope_email"
    git config --file "$local_config" "includeIf.gitdir:${scope}.path" "$scope_config"
    index=$((index + 1))
  done
}

configure_github_ssh() {
  if $DRY_RUN; then
    log "Would authenticate GitHub CLI and configure an SSH key for github.com"
    return
  fi

  if ! command -v gh >/dev/null 2>&1; then
    printf 'GitHub CLI is unavailable; cannot configure GitHub SSH access.\n' >&2
    return 1
  fi

  if [[ ! -t 0 ]]; then
    printf 'GitHub SSH setup is interactive and requires a terminal.\n' >&2
    return 1
  fi

  # GitHub CLI detects existing keys and offers to generate and upload a new
  # key when needed. It also records SSH as the Git protocol for github.com.
  gh auth login --hostname github.com --git-protocol ssh --web
}

ensure_command_line_tools
ensure_homebrew

if command -v brew >/dev/null 2>&1; then
  run brew bundle --file "${REPO_DIR}/Brewfile"
fi

link_path "${REPO_DIR}/.zshrc" "${HOME}/.zshrc"
configure_starship
install_lazyvim
link_path "${REPO_DIR}/.gitconfig" "${HOME}/.gitconfig"

configure_git_identity

if $SETUP_GITHUB_SSH; then
  configure_github_ssh
fi

if ! $SKIP_AGENTS; then
  install_native_agent "Pi" pi "https://pi.dev/install.sh" sh
fi

if ! $SKIP_NVIM_SYNC; then
  if command -v nvim >/dev/null 2>&1; then
    run nvim --headless "+Lazy! sync" +qa
  elif ! $DRY_RUN; then
    log "Neovim is unavailable; skipped LazyVim synchronization"
  fi
fi

if $APPLY_MACOS_DEFAULTS; then
  run "${REPO_DIR}/scripts/macos-defaults.sh"
fi

log "Setup complete. Open a new Ghostty window, run scripts/doctor.sh, then authenticate gh and each managed coding agent."
