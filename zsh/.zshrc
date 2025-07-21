# Q pre-block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] \
  && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Homebrew (Apple Silicon) in PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add local bin to PATH for custom tools
export PATH="$HOME/.local/bin:$PATH"

# Use Starship prompt instead of Oh My Zsh themes
ZSH_THEME=""


# Essential plugins
plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
  zsh-autocomplete
  golang

)

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Initialize Starship prompt
eval "$(starship init zsh)"

##### Convenience Enhancements #####

# Case-insensitive globbing & matching
setopt nocaseglob nocasematch

# Case-insensitive tab-completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 

# Fuzzy file/directory finder (if installed)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Your preferred editor
export EDITOR='nvim'

# Alieses
alias "tm"="tmux"
alias "vi"="nvim"
alias "vim"="nvim"
alias "ll"="ls -la"

# GOLANG
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export GOBIN=$GOPATH/bin
eval "$(mise activate zsh)"

# Source additional zsh configurations
if [[ -d "$HOME/.zshrc.d" ]]; then
    for file in "$HOME/.zshrc.d"/*.zsh; do
        [[ -r "$file" ]] && source "$file"
    done
fi

# Q post-block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] \
  && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
