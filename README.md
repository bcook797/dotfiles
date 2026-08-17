# macOS workstation setup

This repository bootstraps a focused macOS development environment with Homebrew, native Zsh, Ghostty, Starship, LazyVim, and several coding-agent harnesses. It is safe to rerun and backs up conflicting dotfiles instead of overwriting them.

## Fresh-machine setup

Install Apple's Command Line Tools, clone this repository, and run the bootstrap:

```sh
xcode-select --install
git clone git@github.com:bcook797/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

If Command Line Tools are still installing, rerun `./setup.sh` after they finish. Homebrew will be installed automatically when needed.

Preview all bootstrap actions without making changes:

```sh
./setup.sh --dry-run
```

Other options:

```text
--skip-agents      Skip native-only coding-agent harnesses
--refresh-agents   Re-run native-only installers when commands exist
--skip-nvim-sync   Skip the headless LazyVim plugin synchronization
--macos-defaults   Apply the reviewed, opt-in macOS preferences
```

Conflicting files are moved to `~/.dotfiles-backup/<timestamp>/`. The script never removes extra Homebrew packages or old agent installations.

## What is managed

The Brewfile owns the universal desktop and CLI baseline. Repository files are linked into their standard locations for Zsh and Git. Ghostty uses its built-in defaults. The bootstrap installs the official LazyVim starter directly in `~/.config/nvim`, while Starship's official Catppuccin Powerline preset is generated locally during setup.

Language runtimes are intentionally not installed globally. mise is activated in Zsh so projects can declare their own versions with commands such as `mise use node@lts`.

Claude Code, Codex, and OpenCode are managed by Homebrew. Claude Code is allowed to apply targeted Homebrew upgrades in the background. Pi remains on its documented vendor installer because it has no official Homebrew package. Project runtime versions still belong to mise rather than this repository. Agent credentials, sessions, caches, plugins, and memories remain local and untracked.

## After setup

Open a new Ghostty window, then run:

```sh
./scripts/doctor.sh
gh auth login
```

Launch `claude`, `codex`, `opencode`, and `pi` once each and complete their interactive authentication flows. No provider keys or authentication files are stored in this repository.

Run `:LazyHealth` inside Neovim after its initial synchronization. Customize the local starter in `~/.config/nvim`; Neovim configuration is intentionally not tracked by this repository.

To intentionally regenerate the current official Starship preset, remove or back up `~/.config/starship.toml` and run:

```sh
starship preset catppuccin-powerline -o ~/.config/starship.toml
```

Plugin versions and local LazyVim customizations are intentionally not committed to this repository.

## Git identities

The bootstrap prompts for a default Git name/email and any directory-scoped identities. The tracked `.gitconfig` contains shared aliases and defaults; personal values are written to untracked `~/.gitconfig.local` and optional scoped identity files.

For non-interactive setup, provide:

```sh
DOTFILES_GIT_NAME="Your Name" DOTFILES_GIT_EMAIL="you@example.com" ./setup.sh
```

## Maintenance

Run `brew update && brew upgrade` for Homebrew-managed software. Native agents update themselves where supported or can be refreshed with `./setup.sh --refresh-agents`.

Before adding software, consult [the inventory](docs/software-inventory.md). Universal tools belong in the Brewfile; specialized tools remain documented until they warrant inclusion. Add another native coding harness by following the existing installer entries and extending the doctor version check.
