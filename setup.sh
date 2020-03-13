#Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install RVM, ruby, and rails
curl -L https://get.rvm.io | bash -s stable --rails

# Install tools
brew bundle Brewfile

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
