# Dotfiles Repository Guidelines

## File Organization

```
dotfiles/
  <package>/          # GNU Stow package
    .config/<app>/    # config files (mirrors ~/.config layout)
```

Group related settings into clearly labeled sections. Order sections logically (e.g., Core → Appearance → Behavior → Key Bindings → Plugins).

## Section Headers

Use 78-char hash-ruler dividers with the language's comment syntax:

```shell
# Shell / Tmux / Gitconfig
##############################################################################
# Section Name
##############################################################################
```

```lua
-- Lua
-- ##############################################################################
-- # Section Name
-- ##############################################################################
```

```jsonc
// JSONC
// ==============================================================================
// Section Name
// ==============================================================================
```

```toml
# TOML
# ------------------------------------------------------------------------------
# Section Name
# ------------------------------------------------------------------------------
```

## Conventions by File Type

- **Shell (.zshrc)**: 2-space indent for continuations, blank lines between groups
- **Lua**: 2-space indent, trailing commas in tables, `return` a table for plugin specs
- **JSONC**: 2-space indent, trailing commas allowed, double-quoted strings
- **TOML**: standard TOML, `[section]` headers, meaningful module names
- **Tmux**: standard tmux syntax, inline comments with `#`

## Inline Comments

Add a short inline comment before each group of related settings explaining what it does. No need to comment obvious single lines.

## Commit Style

Use conventional commits: `type(scope): description`
- Types: feat, fix, chore, docs, refactor, test, style, ci, perf, revert
- Scope: the stow package name (zed, nvim, tmux, starship, wezterm, zsh, github, opencode)
- Description: lowercase, imperative mood, no trailing period, under 72 chars
