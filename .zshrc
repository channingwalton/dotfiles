# added to make git signing with GPG work. See https://github.com/Homebrew/homebrew-core/issues/14737
export GPG_TTY=$(tty)

export XDG_CONFIG_HOME="$HOME/.config"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"

plugins=(aliases brew git github fzf-tab macos sbt scala wd z)

source $ZSH/oh-my-zsh.sh

export DEFAULT_USER=channing
export EDITOR=nvim

# uv - default to Python 3.13 (3.14 is pre-release and breaks packages)
export UV_PYTHON=3.13

# zstyle 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Set up homebrew (hardcoded to avoid subprocess on every shell launch)
FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
export HOMEBREW_DOWNLOAD_CONCURRENCY=auto

alias cp='cp -i'
alias kj='killall java'
alias kruby='pkill -f rb-fsevent'
alias ls=lsd
alias mv='mv -i'
alias rm='rm -i'
alias up='cd ..'
alias v=nvim
alias vi=nvim
alias vim=nvim

# sbt / mill
alias sup='sbt ";dependencyUpdates; reload plugins; dependencyUpdates"'
alias sfmt='sbt scalafmtAll'

# git
alias gclean='git clean -fdx'
alias gcleand='find . -name .git -print -execdir git clean -fdx \;'
alias gcmd='find . -name .git -print -execdir git checkout main \;'
alias gld='find . -name .git -print -execdir git pull \;'
alias gsd='find . -name .git -print -execdir git status \;'
alias lg=lazygit

# docker
alias kd=killDockerServices
alias ddc=deleteDockerContainers

# devtool
alias cc='devtool check'
alias compile='devtool compile'

export DIRENV_ALLOW=$HOME

# paths
export MY_BIN="$HOME/dotfiles/bin"
export PATH="${MY_BIN}:$PATH"

export PATH="$HOME/Library/Application Support/Coursier/bin:$PATH"
eval "$(cs java --jvm zulu:25 --env)"

export PATH="/Applications/OrbStack.app/Contents/MacOS/xbin:$PATH"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

export OPENAI_API_KEY=$(security find-generic-password -w -s open-ai-api-key)
export GITHUB_PERSONAL_ACCESS_TOKEN=$(security find-generic-password -w -s github-personal-access-token)

# Load tools etc
zmodload -i zsh/complist

eval "$(fzf --zsh)"
eval "$(direnv hook zsh)"
eval "$(atuin init zsh)"

source ~/dotfiles/zshfunctions

export UCM_MERGETOOL='"~/Applications/IntelliJ\ IDEA\ Community\ Edition.app/Contents/MacOS/idea" merge "$LOCAL" "$REMOTE" "$BASE" "$MERGED"'

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

export UNISON_PAGER=cat

# Go
export GOBIN=~/dev/gobin
export PATH="$GOBIN:$PATH"

eval "$(rbenv init - zsh)"

# pnpm
export PNPM_HOME="/Users/channing/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
