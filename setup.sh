#Install Homebrew
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install tools
brew bundle

# configure git to store your password
git config --global credential.helper osxkeychain

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cp bullet-train.zsh-theme ~/.oh-my-zsh/themes/bullet-train.zsh-theme
cp ~/.zshrc ~/.zshrc.orig
cp .zshrc ~/.zshrc

# Install oh-my-zsh custom plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Create Git Aliases
git config --global alias.pr pull -r
git config --global alias.ps push
git config --global alias.st status
git config --global alias.co checkout
