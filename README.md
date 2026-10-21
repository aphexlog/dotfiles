# dotfiles

Personal dotfiles managed with GNU Stow for easy installation and management.

## Prerequisites

### Required
Install GNU Stow:

```bash
brew install stow
```

### Zsh Dependencies
The Zsh setup uses native completion menus plus one suggestions plugin and one
syntax highlighter. It does not require Oh My Zsh or overlapping completion
frameworks.

On Omarchy:

```bash
omarchy pkg add zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
```

Mise, Starship, Zoxide, and fzf use their native Zsh integrations when installed.
On macOS, Homebrew is detected when present; the suggestion and highlighting
plugins can be installed with `brew install zsh-autosuggestions zsh-syntax-highlighting`.

## Available Configurations

- **zsh** - Zsh shell configuration (`.zshrc`)
- **wezterm** - WezTerm terminal emulator configuration (`.wezterm.lua`)
- **starship** - Starship prompt configuration (`starship.toml`)
- **git** - Git configuration (`.gitconfig`)
- **vim** - Vim editor configuration (`.vimrc`)
- **nvim** - Neovim configuration
- **foot** - Foot terminal settings, including font size and key bindings
- **hypr** - Current Omarchy/Hyprland user configuration, including monitor and trackpad settings
- **omarchy** - Omarchy shell config: per-monitor wallpaper service, picker, and menu override
- **opencode** - OpenCode settings, agents, commands, and persistent instructions
- **local-llm** - Local-model scripts, manifest, inventory, and user service; no weights or binaries
- **steam** - Steam desktop launcher with explicit 1× application scaling
- **waybar** - Athena-inspired floating bar with Omarchy controls ([setup](waybar/README.md))
- **matugen** - Wallpaper-derived colors for Waybar only
- **mcp** - MCP server for Amazon Q integration

## Installation

Clone this repository:

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Install specific configurations using Stow:

```bash
# Install individual configurations (see Linux notes before stowing OpenCode)
stow zsh --target ~/
stow wezterm --target ~/
stow starship --target ~/
stow github --target ~/
```

### Linux / Omarchy (keep Bash)

Keep Omarchy's Bash configuration intact and install only configs for applications
you use. Do not run `stow */`: OpenCode service credentials must stay machine-local,
and optional MCP servers need their own dependencies and authentication.

Install Stow with `omarchy pkg add stow`. Clone into `~/Code/dotfiles`, then back
up any conflicting configuration files before linking them. A suitable backup
location is `~/.local/state/dotfiles-backups/<timestamp>/`.

```bash
cd ~/Code/dotfiles

# Git, Neovim, Tmux, and Starship; skip Copilot's optional MCP configuration.
stow --target "$HOME" --ignore='(^|/)\.copilot$' nvim starship tmux github

# OpenCode settings, UI, agents, commands, and instructions; skip service credentials
# and the optional MCP configuration. No folding prevents excluded files being included
# through a whole-directory symlink on a fresh machine.
stow --no-folding --target "$HOME" \
  --ignore='(service\.json|opencode\.jsonc)$' opencode
```

The active OpenCode `opencode.json` is Stow-managed. It preserves SOL's local-model
provider, current default, and persistent instruction registrations; review these
machine-specific choices before applying it on another computer. The separate
`opencode.jsonc` contains optional MCP configuration and is intentionally excluded,
as is the machine-local `service.json`. Back up and compare conflicting live files
before adopting them; do not overwrite them blindly.

The current Hyprland and local-model setup also have dedicated Linux packages:

```bash
# Review monitor connector names, scaling, and host-specific settings first.
stow --no-folding --target "$HOME" hypr local-llm
hyprctl reload
hyprctl configerrors
systemctl --user daemon-reload
```

Stowing `local-llm` links scripts, documentation, the pinned manifest, and its unit;
it does **not** download weights or runtime binaries, start the model, or enable
login autostart. Those artifacts and generated results remain under the real
`~/.local/share/local-llm/` directory, outside this repository. See its Stow-managed
`README.md` and `inventory.md` for model operations and the user's preferences.

### Per-monitor wallpapers

Stock Omarchy paints one background on every output. The `omarchy` package adds a
shell service that paints a second background above it, keyed by screen
**orientation** rather than connector name, because the DisplayPort MST hub on this
machine renumbers DP-12/DP-7 to DP-13/DP-8:

```bash
stow --no-folding --target "$HOME" omarchy
omarchy restart shell
```

It links `~/.config/omarchy/shell.json` (which registers the plugin), the
`aphexlog.monitor-wallpaper` service, the `style.background` menu override, and
`~/.local/bin/wallpaper-monitor-pick`. The picker opens the usual image menu for the
monitor under the pointer (`SUPER + CTRL + SPACE`, or menu → Style → Background) and
applies the choice to that screen only: landscape goes through
`omarchy-theme-bg-set`, portrait is stored in
`~/.config/omarchy/monitor-wallpapers.json` and rendered by the plugin.

Wallpaper art is **not** in this repository. `wallpaper-monitor-pick` reads
`~/Pictures/wallpapers/monitors/{left,right}` (16:9 and 9:16 sets), and that
directory's `README.md` lists every source URL and the undo steps. `monitor-wallpapers.json`
is machine-local runtime state and is intentionally untracked; the picker recreates
it on first use. The linked `shell.json` also registers the separately installed
`io.github.wesleycole.google-drive` bar plugin, so drop that entry (and its tray
item) on a machine without it.

Foot and Steam have their own packages as well:

```bash
stow --no-folding --target "$HOME" foot steam
update-desktop-database "$HOME/.local/share/applications"
```

Foot's font setting applies to new terminals; existing windows can use **Ctrl+=**
to increase their font in 0.5 pt steps without closing the shell. Steam's user
desktop entry preserves the system launcher's actions and URI handling, but sets
`GDK_SCALE=1` and `GDK_DPI_SCALE=1` so stale launcher environments cannot double its
interface size. Steam game data and private account settings are not stored here.

If `~/.config/tmux/tmux.conf` exists, back it up and replace its contents with
`source-file ~/.tmux.conf`, so Tmux and TPM both use the Stow-managed config.
Install TPM if it is missing, then load the config and plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source-file ~/.tmux.conf
~/.tmux/plugins/tpm/bin/install_plugins
tmux source-file ~/.tmux.conf
```

Tmux uses **Ctrl+S** as its prefix and `wl-copy` for the Wayland clipboard.
Neovim inherits the current shell rather than requiring Zsh. Open Neovim to let
Lazy and Mason install its plugins and tools; Go tooling is installed only when
Go is available. Zed and WezTerm can remain unstowed until those apps are needed.

### Optional Zsh shell on Omarchy

Install the Zsh dependencies above, then link and test the configuration before
changing the login shell:

```bash
cd ~/Code/dotfiles
stow --target "$HOME" zsh
zsh
```

Use **Tab** to open/cycle the completion menu, **arrow keys** to navigate, and
**Shift+Tab** to cycle backward. Inline history suggestions can be accepted with
**Right Arrow** at the end of the line. fzf keeps **Ctrl+R**, **Ctrl+T**, **Alt+C**,
and `**` followed by Tab for fuzzy completion.

The compatibility layer preserves Omarchy's environment and aliases, delegates
Bash-only helpers and command completion to the installed Bash definitions, and
loads the shell-neutral worktree helpers natively so `ga`/`gd` still change the
current directory. Desktop settings, terminal theming, and Bash startup files are
not modified. This is user-maintained Zsh integration, not a stock Omarchy setup;
future changes to Omarchy's shell files may need compatibility adjustments.

After testing, change the default shell from your terminal:

```bash
chsh -s /usr/bin/zsh

# If a Tmux server is already running, use Zsh for its new panes/windows too.
tmux set-option -g default-shell /usr/bin/zsh
```

Open a new terminal afterward. Log out and back in if an application still inherits
the old `SHELL` environment. Existing shells are not replaced. For a temporary
fallback, run `bash`; to restore Bash as the login shell, run
`chsh -s /usr/bin/bash` and update Tmux's `default-shell` similarly.

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
