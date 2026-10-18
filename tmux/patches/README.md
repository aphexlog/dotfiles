# Dracula Git directory fallback

This patch preserves spaces in the no-repository label and supports
`#{pane_current_path}` as a fallback, shortening the home directory to `~`.

After installing the Dracula plugin, apply from the dotfiles repository:

```sh
git -C "$HOME/.tmux/plugins/tmux" apply --unidiff-zero "$PWD/tmux/patches/dracula-git-path.patch"
tmux source-file ~/.tmux.conf
```

The patch is already applied on this machine. Plugin updates may require reapplying
or adapting it.
