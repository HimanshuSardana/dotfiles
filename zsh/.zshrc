# PROMPT='%B[%F{blue}%n%f@%F{red}%m%f]%b %F{blue}$(basename $(dirname $PWD))/$(basename $PWD)%f %F{green}❯%f '
PS1='%B[%F{blue}%n%f@%F{red}%m%f]%b %F{blue}%~%f %F{green}❯%f '

HISTFILE=~/.history
HISTSIZE=100000
SAVEHIST=100000

setopt inc_append_history

autoload -U compinit && compinit

setopt menucomplete
setopt automenu

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

bindkey -e
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward

alias v='nvim'
alias o='xdg-open'
alias g='git'

# color
alias ls='ls --color=auto -hv'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c=auto'

alias l='ls'
alias ll='ls -l'
alias la='ls -lA'

alias mv='mv -i'

precmd () { print -Pn "\e]2;%-3~\a"; }

eval "$(zoxide init zsh)"

export HOME="/home/himanshu"
export PATH="$PATH:$HOME/.local/bin"
export BROWSER="zen-browser"
export EDITOR="nvim"

alias c=clear

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

function yz() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

function ginit() {
	eval $(ssh-agent)
	ssh-add ~/.ssh/id_himanshu
}
source <(fzf --zsh)

function tsess() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: tsess <filename.typ>"
    return 1
  fi

  local file="$1"
  local filename="${file%.typ}"
  
  if [[ -n "$TMUX" ]]; then
    # Split window into 3 panes
    tmux split-window -h "nvim '$file'"
    tmux split-window -v "typst watch '$file'"
    tmux select-pane -t 0
    tmux send-keys "zathura '${filename}.pdf'" C-m
  else
    # Start a new tmux session
    tmux new-session -d -s tsess "nvim '$file'"
    tmux split-window -h "typst watch '$file'"
    tmux split-window -v "zathura '${filename}.pdf'"
    tmux select-pane -t 0
    tmux attach-session -t tsess
  fi
}
export DISPLAY=:0

ghc() {
  local reponame="${1:-${PWD##*/}}"

  gh repo create "$reponame" --public

  [[ ! -d .git ]] && git init

  git add .
  git commit -m "Initial commit"
  git branch -M main
  git remote add origin "git@github.com:$(gh api user --jq .login)/$reponame.git" 2>/dev/null
  git push -u origin main
}

ghcp() {
  local reponame="${1:-${PWD##*/}}"

  gh repo create "$reponame" --private 

  [[ ! -d .git ]] && git init

  git add .
  git commit -m "Initial commit"
  git branch -M main
  git remote add origin "git@github.com:$(gh api user --jq .login)/$reponame.git" 2>/dev/null
  git push -u origin main
}

# delete github repo in current directory
function ghd() {
  local reponame="${PWD##*/}"
  gh repo delete "$reponame" --confirm
}
