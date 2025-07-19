# dotfiles

Personal dotfiles managed with GNU Stow for easy installation and management.

## Prerequisites

Install GNU Stow:

```bash
brew install stow
```

## Available Configurations

- **zsh** - Zsh shell configuration (`.zshrc`)
- **wezterm** - WezTerm terminal emulator configuration (`.wezterm.lua`)
- **starship** - Starship prompt configuration (`starship.toml`)
- **git** - Git configuration (`.gitconfig`)
- **vim** - Vim editor configuration (`.vimrc`)
- **nav** - Code navigation utility with smooth workspace management

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
stow git --target ~/

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
