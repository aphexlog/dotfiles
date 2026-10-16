##############################################################################
# Core
##############################################################################

# Use Homebrew when present without requiring it on Linux.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Keep Omarchy's environment, aliases, and Bash-only helpers available.
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/omarchy.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/omarchy.zsh"
fi

# Preserve system PATH precedence and avoid duplicate entries.
typeset -U path PATH
export GOPATH="${GOPATH:-$HOME/go}"
export GOBIN="${GOBIN:-$GOPATH/bin}"
path+=("$HOME/.local/bin" "$GOBIN")
export EDITOR="${EDITOR:-nvim}"

##############################################################################
# History
##############################################################################

# Keep shared Zsh history separate from Bash's history.
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=32768
SAVEHIST=32768
mkdir -p -- "${HISTFILE:h}"
setopt extended_history share_history hist_ignore_all_dups hist_ignore_space
setopt hist_save_no_dups hist_reduce_blanks

##############################################################################
# Completion / UX
##############################################################################

# Initialize secure, cached native completion and an arrow-navigable menu.
fpath=("${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completions" $fpath)
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)
mkdir -p -- "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zmodload zsh/complist
(( $+functions[zd] )) && compdef _cd zd
setopt auto_menu auto_list complete_in_word nocaseglob
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'
[[ -n "${LS_COLORS:-}" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
if [[ -r "${OMARCHY_PATH:-}/default/bash/completions" ]]; then
  zstyle ':completion:*:*:-command-:*' ignored-patterns 'omarchy-*'
fi

# Keep familiar editing keys and prefix-based Up/Down history searches.
bindkey -e
bindkey '^I' menu-complete
bindkey '^[[Z' reverse-menu-complete
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

# Keep navigation and deletion consistent across modern terminal emulators.
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

##############################################################################
# Tool Integrations
##############################################################################

# Use native Zsh integrations rather than sourcing Bash initialization.
(( $+commands[mise] )) && eval "$(mise activate zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
if (( $+commands[fzf] )) && [[ -o zle && -t 0 && -t 1 ]]; then
  source <(fzf --zsh)
fi
(( $+commands[starship] )) && eval "$(starship init zsh)"

# Granted must be sourced to update AWS credentials in the current shell.
if (( $+commands[assumego] && $+commands[assume] )); then
  alias assume="source ${(q)commands[assume]}"
fi

# Match Omarchy's lazy initialization of its ephemeral workspace helper.
if (( $+commands[try] )); then
  try() {
    unfunction try
    eval "$(SHELL=/bin/zsh command try init "$HOME/Work/tries")"
    try "$@"
  }
fi

##############################################################################
# Autosuggestions
##############################################################################

# Load one suggestion plugin, using system packages or an existing macOS copy.
ZSH_AUTOSUGGEST_USE_ASYNC=1
for plugin in \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  if [[ -r "$plugin" ]]; then
    source "$plugin"
    break
  fi
done
unset plugin

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
  for file in "$HOME/.zshrc.d"/*.zsh(N); do
    [[ -r "$file" ]] && source "$file"
  done
  unset file
fi

##############################################################################
# Syntax Highlighting
##############################################################################

# Keep a single highlighter last, after every widget and keybinding is defined.
for plugin in \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  if [[ -r "$plugin" ]]; then
    source "$plugin"
    break
  fi
done
unset plugin
