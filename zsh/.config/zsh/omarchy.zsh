##############################################################################
# Omarchy Compatibility
##############################################################################

[[ -r "${OMARCHY_PATH:-}/default/bash/aliases" ]] || return 0

# These environment and alias files use syntax supported by both shells.
source "$OMARCHY_PATH/default/bash/envs"
source "$OMARCHY_PATH/default/bash/aliases"

# Preserve command-plus-arguments editors, which Zsh does not split implicitly.
alias eff='${=EDITOR} "$(ff)"'
alias decompress='tar -xzf'

# Execute Bash-specific helpers in Bash, preserving their original semantics.
_omarchy_bash_helper() {
  command bash --noprofile --norc -c '
    source "$OMARCHY_PATH/default/bash/functions"
    "$@"
  ' omarchy-zsh "$@"
}

# Discover helpers from the installed Omarchy version instead of freezing a list.
for helper in ${(f)"$(command bash --noprofile --norc -c '
  source "$OMARCHY_PATH/default/bash/functions"
  declare -F | while read -r _ _ name; do printf "%s\n" "$name"; done
')"}; do
  functions[$helper]="_omarchy_bash_helper ${(q)helper} \"\$@\""
done
unset helper

# Worktree helpers must change the parent shell's directory; their source is
# shell-neutral, so load those natively rather than using the subprocess bridge.
source "$OMARCHY_PATH/default/bash/fns/worktrees"
