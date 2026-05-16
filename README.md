# dotfiles

Personal dotfiles managed with GNU Stow for easy installation and management.

## Prerequisites

### Required
Install GNU Stow:

```bash
brew install stow
```

### Zsh Dependencies
The zsh configuration requires these tools for full functionality:

```bash
# Core completions (provides flag descriptions for 600+ commands)
brew install carapace

# Fuzzy completion menu
brew install fzf-tab

# Starship prompt
brew install starship

# Oh-My-Zsh (if not already installed)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Oh-My-Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
```

The `.zshrc` will show warnings for any missing tools when you open a new shell.

## Available Configurations

- **zsh** - Zsh shell configuration (`.zshrc`)
- **wezterm** - WezTerm terminal emulator configuration (`.wezterm.lua`)
- **starship** - Starship prompt configuration (`starship.toml`)
- **git** - Git configuration (`.gitconfig`)
- **vim** - Vim editor configuration (`.vimrc`)
- **nvim** - Neovim configuration
- **mcp** - MCP server for Amazon Q integration

## Installation

Clone this repository:

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Install specific configurations using Stow:

```bash
# Install individual configurations
stow zsh --target ~/
stow wezterm --target ~/
stow starship --target ~/
stow github --target ~/

# Install all configurations at once
stow */ --target ~/
```

## Uninstalling

Remove configurations using Stow's delete option:

```bash
# Remove specific configuration
stow -D zsh --target ~/

# Remove all configurations
stow -D */ --target ~/
```

## How it works

GNU Stow creates symlinks from your home directory to the files in this repository. Each subdirectory represents a "package" that contains the dotfiles for a specific application, organized in the same structure as they would appear in your home directory.

For example, running `stow wezterm` will create a symlink at `~/.wezterm.lua` pointing to `~/dotfiles/wezterm/.wezterm.lua`.
