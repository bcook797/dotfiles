# Software inventory

This catalog preserves the intent found in the current machine, the working Brewfile, and the repository's history. Only the default baseline is executable. Other entries are retained here so they can be reconsidered deliberately instead of being forgotten.

## Default baseline

### Desktop applications

- Browsers: Google Chrome, Firefox
- Communication and knowledge: Zoom, Obsidian, Slack
- Security and networking: 1Password, Outline Manager
- Development: Ghostty, Visual Studio Code, JetBrains Mono Nerd Font

### Command-line tools

- Shell: Starship, mise, herdr, zsh-autosuggestions, zsh-syntax-highlighting
- Version control: Git, GitHub CLI, tig, lazygit
- Essentials: ripgrep, fd, fzf, jq, tree
- Editor: Neovim, LazyVim, tree-sitter CLI
- Coding-agent harnesses: Claude Code, Codex, OpenCode, Pi, Gemini CLI

## Viable manual or specialized installs

These remain useful, but are not universal enough for the minimal bootstrap.

- Languages and build tools: OpenJDK 21, Maven, Ant, Dart SDK, Python, Go, Rust, Node.js
- Containers: Podman, Docker CLI compatibility, Docker Compose, lazydocker, Colima, Docker Desktop
- Terminal/editor alternatives: tmux, Vim, IntelliJ IDEA, Cursor, iTerm2
- Testing and automation: Playwright CLI, adr-tools
- Unix/build utilities: wget, ack, ctags, autoconf, automake, libtool, libyaml, OpenSSL
- Desktop utilities: ChatGPT, Claude Desktop, balenaEtcher, GPG Suite, Tunnelblick, DaisyDisk, Dropbox, VLC, LibreOffice
- Developer/data clients: Bruno, Insomnia, Postman, DBeaver Community

Runtimes should normally be declared by individual projects through mise. Install a global runtime only when a concrete workflow requires it.

## Retired, replaced, or unavailable

- Oh My Zsh and Bullet Train: replaced by native Zsh and Starship.
- NVM: no longer bootstrapped; mise is available for project-owned Node versions.
- Authy Desktop: discontinued and not suitable for a new-machine baseline.
- Outline's older `outline` cask: replaced by Outline Manager.
- Docker aliasing through Podman: machine-specific and no longer placed in global shell configuration.
- Pow, heroku-toolbelt, ccmenu18, Screenhero, Sequel Pro, Atom, Sublime Text, MacVim: obsolete or superseded for this workflow.
- Java 6, Silverlight, Mono MDK, Xamarin Studio, Visual Studio for Mac: retired platforms.
- VirtualBox and Vagrant: excluded from the universal baseline; use a current container or virtualization choice when required.
- MongoDB, Elasticsearch, Logstash, PostgreSQL, SQLite, MySQL, Memcached, Redis: project services rather than workstation-global defaults.
- Mercurial, Leiningen, Android NDK/platform tools, XQuartz, PCKeyboardHack: historical entries with no current requirement.

## Adding something new

Add universal GUI applications and CLI tools to the Brewfile. Add coding harnesses to the native-agent registry in `setup.sh` when their vendor installer has a concrete advantage. Record specialized or experimental software here first; promote it to the baseline only after it proves broadly useful.
