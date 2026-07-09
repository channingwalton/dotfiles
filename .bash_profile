[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

# Activate mise last so its toolchain wins over RVM and macOS path_helper.
# .bash_profile (not .bashrc) is what `bash -lc` reads, so agents and scripts
# get the locked ruby/node/java rather than system Ruby 2.6.
command -v mise >/dev/null && eval "$(mise activate bash)"
