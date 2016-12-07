#Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install RVM, ruby, and rails
curl -L https://get.rvm.io | bash -s stable --rails

# Install tools
brew bundle Brewfile

# Install apps
brew bundle Caskfile

# configure git to store your password
git config --global credential.helper osxkeychain

# Install NPM
curl http://npmjs.org/install.sh | sh
