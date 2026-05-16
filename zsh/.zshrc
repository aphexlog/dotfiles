##############################################################################
# Core
##############################################################################

export ZSH="$HOME/.oh-my-zsh"
export TERM=xterm-256color

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# Use Starship instead of an Oh My Zsh theme
ZSH_THEME=""

##############################################################################
# Plugins
##############################################################################

plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
  # zsh-autocomplete
  golang
  aws
  node
  git
  docker
  docker-compose
)

source $ZSH/oh-my-zsh.sh
eval "$(starship init zsh)"

##############################################################################
# Completion / UX
##############################################################################

setopt nocaseglob nocasematch
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Docker Desktop completions
fpath=(/Users/aphexlog/.docker/completions $fpath)
autoload -Uz compinit
compinit

# Carapace completions (command/flag descriptions)
if command -v carapace >/dev/null 2>&1; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  source <(carapace _carapace)
fi

# fzf-tab completion menu
if [[ -f /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh ]]; then
  source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh
fi

##############################################################################
# Environment
##############################################################################

export EDITOR='nvim'
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export GOBIN=$GOPATH/bin
eval "$(mise activate zsh)"

##############################################################################
# Aliases
##############################################################################

alias tm="tmux"
alias vi="nvim"
alias vim="nvim"
alias ll="ls -la"
alias cpc="copilot --silent"
alias q="opencode"

##############################################################################
# Local Overrides
##############################################################################

if [[ -d "$HOME/.zshrc.d" ]]; then
  for file in "$HOME/.zshrc.d"/*.zsh; do
    [[ -r "$file" ]] && source "$file"
  done
fi
