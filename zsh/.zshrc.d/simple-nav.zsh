# Minimal Code Navigation Aliases

# Enhanced navigation - c for Code directory, c -- project for specific project
c() {
    if [[ "$1" == "--" && -n "$2" ]]; then
        cd ~/Code/$2 && pwd && ls
    else
        cd ~/Code && ls
    fi
}

# Quick project listing
alias projects='ls ~/Code'

# Quick project creation
mkp() {
    mkdir -p ~/Code/$1 && cd ~/Code/$1
    echo "# $1" > README.md
    git init . 2>/dev/null
}
