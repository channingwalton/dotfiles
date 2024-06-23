ulimit -n 200000
ulimit -u 2048

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
. "$HOME/.cargo/env"

source /Users/channing/.docker/init-bash.sh || true # Added by Docker Desktop

source /Users/channing/.config/broot/launcher/bash/br
