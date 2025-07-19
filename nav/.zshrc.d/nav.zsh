# Nav CLI Integration
# Shell functions that work with the Go CLI for smooth navigation

# Check if nav CLI is available
if ! command -v nav &> /dev/null; then
    echo "⚠️  Nav CLI not found. Run 'make install' in your nav directory."
    return
fi

# Navigation wrapper functions that actually change directory
forge() {
    local result
    result=$(nav forge "$@" 2>/dev/null)
    if [[ $result == cd* ]]; then
        eval "$result"
        pwd && ls -la
    else
        nav forge "$@"
    fi
}

corp() {
    local result
    result=$(nav corp "$@" 2>/dev/null)
    if [[ $result == cd* ]]; then
        eval "$result"
        pwd && ls -la
    else
        nav corp "$@"
    fi
}

lab() {
    local result
    result=$(nav lab "$@" 2>/dev/null)
    if [[ $result == cd* ]]; then
        eval "$result"
        pwd && ls -la
    else
        nav lab "$@"
    fi
}

archive() {
    local result
    result=$(nav archive "$@" 2>/dev/null)
    if [[ $result == cd* ]]; then
        eval "$result"
        pwd && ls -la
    else
        nav archive "$@"
    fi
}

# Project creation functions that change to the new directory
new_forge() {
    local result
    result=$(nav new forge "$@" 2>/dev/null)
    if [[ $result == cd* ]]; then
        eval "$result"
        pwd && ls -la
    else
        nav new forge "$@"
    fi
}

new_corp() {
    local result
    result=$(nav new corp "$@" 2>/dev/null)
    if [[ $result == cd* ]]; then
        eval "$result"
        pwd && ls -la
    else
        nav new corp "$@"
    fi
}

# Aliases for common commands
alias projects='nav list'
alias find_project='nav find'
alias archive_project='nav archive-project'
alias nav_help='nav --help'

# Initialize workspace on first load
nav init &>/dev/null

echo "🚀 Nav CLI loaded! Type 'nav --help' for commands."
