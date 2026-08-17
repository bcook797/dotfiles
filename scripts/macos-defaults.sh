#!/usr/bin/env bash

set -Eeuo pipefail

# Dock

# Reclaim screen space by hiding the Dock until the pointer reaches its edge.
defaults write com.apple.dock autohide -bool true

# Keep the Dock predictable by omitting recently used applications.
defaults write com.apple.dock show-recents -bool false

# Keep minimized windows from taking up individual slots in the Dock.
defaults write com.apple.dock minimize-to-application -bool true

# Finder

# Make file types explicit, including for scripts, archives, and config files.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show the current location and make parent directories easy to open.
defaults write com.apple.finder ShowPathbar -bool true

# Reload affected applications so the new preferences take effect immediately.
killall Dock Finder 2>/dev/null || true

cat <<'EOF'
Applied approved macOS Dock and Finder preferences.
EOF
