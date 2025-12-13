# added to make git signing with GPG work. See https://github.com/Homebrew/homebrew-core/issues/14737
export GPG_TTY=$(tty)

export XDG_CONFIG_HOME="$HOME/.config"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/Users/channing/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

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

source $ZSH/oh-my-zsh.sh

export DEFAULT_USER=channing
export EDITOR=nvim

# zstyle 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Set up homebrew
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
export HOMEBREW_DOWNLOAD_CONCURRENCY=auto

alias cp='cp -i'
alias kj='killall java'
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

export DIRENV_ALLOW=$HOME

# paths
export MY_BIN=/Users/channing/dotfiles/bin
export PATH=${MY_BIN}:$PATH

export PATH="/Users/channing/Library/Application Support/Coursier/bin:$PATH"
eval "$(cs java --jvm zulu:21 --env)"
export PATH="$JAVA_HOME/bin:$PATH"

export PATH="/Applications/OrbStack.app/Contents/MacOS/xbin:$PATH"

export PATH="/Users/channing/.local/bin:$PATH"
export PATH="/Users/channing/.cargo/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

export OPENAI_API_KEY=$(security find-generic-password -w -s open-ai-api-key)

# Load tools etc
zmodload -i zsh/complist

eval "$(fzf --zsh)"
eval "$(direnv hook zsh)"
eval "$(atuin init zsh)"

source ~/dotfiles/zshfunctions

UCM_MERGETOOL='"~/Applications/IntelliJ\ IDEA\ Community\ Edition.app/Contents/MacOS/idea" merge "$LOCAL" "$REMOTE" "$BASE" "$MERGED"'
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


# Added by Antigravity
export PATH="/Users/channing/.antigravity/antigravity/bin:$PATH"

export UNISON_PAGER=cat
