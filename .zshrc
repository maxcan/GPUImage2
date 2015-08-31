# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"
ZSH_THEME="kphoen"
# ZSH_THEME="miloshadzic"
# ZSH_THEME="dpoggi"
# ZSH_THEME="zhann"
# ZSH_THEME="clean"
# ZSH_THEME="arrow"
# ZSH_THEME="robbyrussell"
# ZSH_THEME="flazz"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
export UPDATE_ZSH_DAYS=30

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(vi-mode)

source $ZSH/oh-my-zsh.sh

# function git_prompt_info() {
#   ref=$(git symbolic-ref HEAD 2> /dev/null) || return
#   echo "foo"
# }

# Customize to your needs...
export PATH=$PATH:./.cabal-sandbox/bin:../.cabal-sandbox/bin:./cabal-dev/bin:/Users/max/.cabal/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/Users/max/bin:./cabal-dev/bin:/Users/max/.cabal/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/Users/max/bin:/Users/max/.rvm/gems/ruby-1.9.3-p286/bin:/Users/max/.rvm/gems/ruby-1.9.3-p286@global/bin:/Users/max/.rvm/rubies/ruby-1.9.3-p286/bin:/Users/max/.rvm/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/share/npm/bin/:/Users/max/Library/Haskell/bin:/Users/max/bin:/Users/max/bin/play:/usr/local/Cellar/aws-iam-tools/1.5.0/jars/bin:/Users/max/.rvm/bin:/usr/local/share/npm/bin/:/Users/max/Library/Haskell/bin:/Users/max/bin:/Users/max/bin/play:/usr/local/Cellar/aws-iam-tools/1.5.0/jars/bin:/Users/max/.rvm/bin:/Users/max/.gem/ruby/2.0.0/bin

# JAVA shit for aws
export JAVA_HOME='/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home'
export AWS_IAM_HOME='/usr/local/Cellar/aws-iam-tools/1.5.0/jars'
export EC2_HOME='/usr/local/Cellar/ec2-api-tools/1.6.7/jars'
export NODE_ENV=dev
export AWS_ACCESS_KEY='AKIAJ2ER3FHDTHX5M5ZA'
export AWS_SECRET_KEY='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'
export AWS_CREDENTIAL_FILE="$HOME/.ec2/iam.creds.txt"
# echo "AWSAccessKeyId=${AWS_ACCESS_KEY}" > $AWS_CREDENTIAL_FILE
# echo "AWSSecretKey=${AWS_SECRET_KEY}" >> $AWS_CREDENTIAL_FILE
autoload -U compinit
compinit

# Asana stuff
asanachore()   {echo "Subject:$*\n\n ...from CLI" | sendmail -f max@docmunch.com x+4588376538871@mail.asana.com }
asanasprint()  {echo "Subject:$*\n\n ...from CLI" | sendmail -f max@docmunch.com x+4563229279749@mail.asana.com }
asanabug()     {echo "Subject:$*\n\n ...from CLI" | sendmail -f max@docmunch.com x+4561988334439@mail.asana.com }
asanaroadmap() {echo "Subject:$*\n\n ...from CLI" | sendmail -f max@docmunch.com x+4561988334433@mail.asana.com }
# asanabugs()    {echo "...from CLI" | mail -s "$*" x+4561988334439@mail.asana.com }
# asanaroadmap() {echo "...from CLI" | mail -s "$*" x+4561988334433@mail.asana.com }
setopt completeinword

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:killall:*' command 'ps -u $USER -o cmd'
autoload select-word-style
select-word-style shell
HISTFILE=~/.zhistory
HISTSIZE=SAVEHIST=10000
setopt incappendhistory 
setopt sharehistory
setopt extendedhistory
setopt extendedglob
unsetopt caseglob
setopt interactivecomments # pound sign in interactive prompt
setopt auto_cd
# PS1='> '
# echo $PS1
# autoload -Uz promptinit
# promptinit
# prompt bart blue green

REPORTTIME=10

# export PATH=./cabal-dev/bin:${HOME}/.cabal/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:${HOME}/bin:$PATH
# export PATH=${PATH}:/usr/local/share/npm/bin/
# export PATH=${PATH}:~/Library/Haskell/bin
# export PATH=${PATH}:${HOME}/bin
# export PATH=${PATH}:${HOME}/bin/play
# export PATH=${PATH}:${AWS_IAM_HOME}/bin

export MANPATH=/usr/local/share/man:$MANPATH

alias dt="date '+%Y-%m-%d'"
alias cdv='cabal-dev'
alias cdvii='cabal-dev install'
alias cdvgp='cabal-dev ghc-pkg'
alias cdvll='cabal-dev ghc-pkg list'
alias aws_ssh='ssh -i aws/mxcantor.pem max@ec2-175-41-152-219.ap-southeast-1.compute.amazonaws.com'
alias hsg='history | grep -i '
alias getip='ifconfig | grep -A 3 en0 | grep "inet "'
alias g=git
alias gs='git status'
alias gc='git commit'
alias gch='git checkout'
alias gd='git diff'
alias gfo='git fetch origin'
alias gdc='git diff --color'
alias gcam='git commit -a -m'
alias glp='git log --color -w -p'
alias gmnc='git merge --no-ff --no-commit'
alias pull='git pull origin'
alias push='git push origin'
alias exo='expresso'
alias arlsc='ssh -t a.raiselabs.com screen -x'
set -o vi
bindkey '^R' history-incremental-search-backward
alias loopless='while ((1 < 2 )) { lessc application.less application.less.css ; echo "ran less on `date`" ; sleep 2 } '
alias ds='date +%F'
export TERM=xterm-256color
alias hsact='source .hsenv*/bin/activate'

alias runmongo='mongod run --config /usr/local/etc/mongod.conf'
cd() { pushd "$*" >> /dev/null; }
cdlast() { cd `ls -rt | tail -n 1`}
export LD_LIBRARY_PATH=/usr/local/lib
export PATH=/usr/local/bin:~/.cabal/bin:$PATH
export JAVA_HOME="$(/usr/libexec/java_home)"
# export EC2_PRIVATE_KEY="$(/bin/ls "$HOME"/.ec2/pk-*.pem | /usr/bin/head -1)"
# export EC2_CERT="$(/bin/ls "$HOME"/.ec2/cert-*.pem | /usr/bin/head -1)"
# export EC2_HOME="/usr/local/Cellar/ec2-api-tools/1.6.12.0/libexec"
ulimit -n 8192

. `brew --prefix`/etc/profile.d/z.sh
