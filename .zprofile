# Keep only the first copy of each PATH entry (.zshrc prepends some of these again).
# Both names: -U on the path array alone ignores assignments to the PATH string.
typeset -U PATH path

eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :


# Added by Toolbox App
export PATH="$PATH:/Users/channing/Library/Application Support/JetBrains/Toolbox/scripts"

# Added by Obsidian
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# >>> Codex installer >>>
export PATH="/Users/channing/.local/bin:$PATH"
# <<< Codex installer <<<

# Activate mise for login shells, so `zsh -lc` gets the locked toolchain rather
# than system Ruby 2.6. This must live here, not in ~/.zshenv: /etc/zprofile runs
# path_helper *after* ~/.zshenv and would push mise behind /usr/bin.
# Interactive shells skip it: ~/.zshrc activates mise after its own PATH edits, and
# activating twice cost a second mise run and left stale mise entries on PATH.
if [[ ! -o interactive ]] && command -v mise >/dev/null; then
  eval "$(mise activate zsh)"
fi
