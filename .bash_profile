[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

# Homebrew first, as .zprofile does: path_helper rebuilds PATH from /etc/paths for
# login shells, so a clean environment has no /opt/homebrew/bin and mise lives there.
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# mise activates here, not in .bashrc: `bash -lc` reads .bash_profile only, and it
# must come last so its toolchain wins over path_helper's system Ruby.
command -v mise >/dev/null && eval "$(mise activate bash)"
