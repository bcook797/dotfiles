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