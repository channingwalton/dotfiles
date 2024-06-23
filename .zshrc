# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/Users/channing/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 1

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(aliases brew git github fzf-tab macos sbt scala wd z)

# zstyle 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Set up homebrew completions
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

source $ZSH/oh-my-zsh.sh

export DEFAULT_USER=channing
export EDITOR=nvim

alias bu="updates; omz update"
alias cp='cp -i'
alias df=duf
alias du=dust
alias kj='killall java'
alias ls=lsd
alias mv='mv -i'
alias rm='rm -i'
alias top=btop
alias up='cd ..'
alias v=nvim
alias vi=nvim
alias vim=nvim
alias e='fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs $EDITOR'

# sbt / mill
alias mf='./mill smithy.format'
alias mp='./mill smithy.publishLocal'
alias sfmt='sbt scalafmtFormatAll'
alias sg='sbt "smithy4sCodegen"'
alias sit='sbt it:test'
alias sitr='sbt integrationTests/Test/run'
alias sup='sbt ";dependencyUpdates; reload plugins; dependencyUpdates"'
alias sxm='cd ~/dev/sxm/'
alias sxmenv='source ~/dev/sxm/.envrc'

# git
alias gclean='git clean -fdx'
alias gcleand='find . -name .git -print -execdir git clean -fdx \;'
alias gcmd='find . -name .git -print -execdir git checkout main \;'
alias gld='find . -name .git -print -execdir git pull \;'
alias gsd='find . -name .git -print -execdir git status \;'

# functions
function ff {
  fzf --preview "bat --color always {}" | xargs nvim
}

function updates {
  brew update
  brew upgrade
  brew upgrade --cask
  brew cleanup
  brew autoremove
  espanso package update all
  coursier update
}

function killDockerServices {
  if [[ $(docker ps -q | wc -c) -eq 0 ]]; then
    echo "Nothing running"
  else
    docker kill $(docker ps -q)
    docker ps
  fi
}
alias kd=killDockerServices

function deleteDockerContainers {
  if [[ $(docker ps -a -q | wc -c) -eq 0 ]]; then
    echo "No containers"
  else
    docker rm -f $(docker ps -a -q)
  fi
}
alias ddc=deleteDockerContainers

function tailDockerLogs {
  if [ -z "$1" ]; then
    echo "name missing"
    exit
  fi

  id=$(docker ps -f name=$1 --format "{{.ID}}")
  if [[ -z $id ]]
  then
    sleep 2
    tailDockerLogs $1
  else
    docker logs -f $id
  fi
}

function siriusLogin {
  source ~/dev/sxm/.envrc
  scripts/artifactory-credentials.sh
}
alias sl=siriusLogin

function sxmup {
  open -a /Applications/Arc.app
  open -a /Applications/Slack.app
  open -a /Applications/Obsidian.app

  updates
  cd ~/dev/sxm
}

function siriusValidate {
  source ~/dev/sxm/.stripe.env
  siriusLogin && sbt "scalafmtFormatAll; clean; validate"
}
alias scv=siriusValidate

function siriusCDKBuild {
  unset STRIPE_API_KEY_USD
  unset STRIPE_ACCOUNT_ID_USD
  cd infrastructure && npm install && npx jest --updateSnapshot && cd ..
}
alias scdk=siriusCDKBuild

jwt-decode() {
  jq -R 'split(".") |.[0:2] | map(@base64d) | map(fromjson)' <<< $1
}

function siriusStatus {
  east2=`curl -sk https://$1-service.us-east-2.commerce.$2.cloud.siriusxm.com/internal/meta/health`
  east1=`curl -sk https://$1-service.us-east-1.commerce.$2.cloud.siriusxm.com/internal/meta/health`
  west2=`curl -sk https://$1-service.us-west-2.commerce.$2.cloud.siriusxm.com/internal/meta/health`

  echo $2
  echo "east2: $east2"
  echo "east1: $east1"
  echo "west2: $west2"
}

function siriusVersion {
  east2=`curl -sk https://$1-service.us-east-2.commerce.$2.cloud.siriusxm.com/internal/meta/version`
  east1=`curl -sk https://$1-service.us-east-1.commerce.$2.cloud.siriusxm.com/internal/meta/version`
  west2=`curl -sk https://$1-service.us-west-2.commerce.$2.cloud.siriusxm.com/internal/meta/version`

  echo $2
  echo "east2: $east2"
  echo "east1: $east1"
  echo "west2: $west2"
}

function openMockserver {
  if [[ -z $(docker ps --format "{{.ID}}") ]]
  then
    echo "No containers are running in docker"
  else
    ports=$(docker ps -f name=mockserver --format "{{.Ports}}")
    if [[ -z $ports ]]
    then
      echo "mockserver is not running"
    else
      port=$(echo "$ports" | grep -Eo ':[0-9]+->' | grep -Eo '[0-9]+')
      open "http://localhost:$port/mockserver/dashboard"
    fi
  fi
}

pman() {
    man -t ${@} | open -f -a Preview
}

# paths
export MY_BIN=/Users/channing/dotfiles/bin
export PATH=${MY_BIN}:$PATH
export OPENAI_API_KEY=$(security find-generic-password -w -s open-ai-api-key)

export GEM_HOME="$HOME/.gem"
export PATH="$GEM_HOME/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

export PATH="/Users/channing/Library/Application Support/Coursier/bin:$PATH"
export PATH="/Users/channing/.local/bin:$PATH"
export PATH="/Users/channing/.cargo/bin:$PATH"

# added to make git signing with GPG work. See https://github.com/Homebrew/homebrew-core/issues/14737
GPG_TTY=$(tty)
export GPG_TTY

# Load tools etc

autoload -U compinit && compinit
zmodload -i zsh/complist

eval "$(fzf --zsh)"

eval "$(direnv hook zsh)"

source /Users/channing/.docker/init-zsh.sh || true # Added by Docker Desktop

source $HOME/.sde/profile/profile.sh

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

eval "$(atuin init zsh)"

source /Users/channing/.config/broot/launcher/bash/br

