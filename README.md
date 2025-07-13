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

## Installation

Clone this repository:

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Install specific configurations using Stow:

```bash
# Install individual configurations
stow zsh
stow wezterm
stow starship
stow git

# Install all configurations at once
stow */
```

## Uninstalling

Remove configurations using Stow's delete option:

```bash
# Remove specific configuration
stow -D zsh

# Remove all configurations
stow -D */
```

## How it works

GNU Stow creates symlinks from your home directory to the files in this repository. Each subdirectory represents a "package" that contains the dotfiles for a specific application, organized in the same structure as they would appear in your home directory.

For example, running `stow wezterm` will create a symlink at `~/.wezterm.lua` pointing to `~/dotfiles/wezterm/.wezterm.lua`.
