
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
# ~/.zshrc keeps its own activate, for non-login interactive shells.
command -v mise >/dev/null && eval "$(mise activate zsh)"
