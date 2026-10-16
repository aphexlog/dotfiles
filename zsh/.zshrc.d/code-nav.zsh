##############################################################################
# Project Navigation
##############################################################################

# Quick project listing
alias projects='ls ~/Code'

# Create a project safely without overwriting an existing README.
mkp() {
  if (( $# != 1 )) || [[ -z "$1" || "$1" == */* || "$1" == . || "$1" == .. ]]; then
    print -u2 -- 'Usage: mkp <project-name> (a single directory name)'
    return 1
  fi

  local project="$HOME/Code/$1"
  mkdir -p -- "$project" && builtin cd -- "$project" || return
  [[ -e README.md ]] || printf '# %s\n' "$1" > README.md
  command git init .
}
