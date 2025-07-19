# 🚀 Nav CLI - Code Navigation Utility

A slick and intuitive Go CLI for navigating your coding workspace with style.

## Features

- **🏗️ Forge** - Personal projects (way cooler than "personal")
- **🏢 Corp** - Work/corporate projects  
- **🧪 Labs** - Experiments and learning projects
- **📦 Archive** - Old/completed projects

## Installation

```bash
# Build and install the CLI
make install

# Or just build it
make build
```

## Usage

### Navigation
```bash
nav forge                    # Navigate to forge directory
nav forge myproject         # Navigate to specific project
nav corp                    # Navigate to corp directory
nav corp workproject        # Navigate to specific work project
nav lab                     # Navigate to labs
nav archive                 # Navigate to archive
```

### Project Management
```bash
nav new forge myproject     # Create new personal project
nav new corp workproject    # Create new work project
nav archive-project old-project forge  # Move project to archive
```

### Discovery
```bash
nav list                    # List all projects organized by type
nav find search-term        # Search for projects across all directories
```

### Initialization
```bash
nav init                    # Initialize workspace directories
```

## Shell Integration

The package includes zsh integration that provides smooth navigation functions:

- `forge [project]` - Navigate with directory listing
- `corp [project]` - Navigate with directory listing  
- `lab [project]` - Navigate with directory listing
- `archive [project]` - Navigate with directory listing
- `new_forge <name>` - Create and navigate to new personal project
- `new_corp <name>` - Create and navigate to new work project
- `projects` - List all projects
- `find_project <term>` - Search for projects

## Project Structure

Each new project is created with:
```
project-name/
├── src/          # Source code
├── docs/         # Documentation
├── tests/        # Test files
├── config/       # Configuration (corp projects only)
├── README.md     # Project README
└── .git/         # Git repository (if git is available)
```

## Directory Structure

```
~/Code/
├── forge/        # Personal projects
├── corp/         # Work projects
├── labs/         # Experiments
└── archive/      # Old projects
```

## Development

```bash
make help         # Show all available commands
make build        # Build the CLI
make install      # Build and install
make clean        # Clean build artifacts
make test         # Run tests
make dev          # Run in development mode
```

## Stow Integration

This package is designed to work with GNU Stow as part of your dotfiles:

```bash
# Install the nav package
stow nav --target ~/

# The CLI will be available after building and installing
cd ~/dotfiles/nav && make install
```
