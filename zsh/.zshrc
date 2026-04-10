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
    tmux split-window -v "typst watch '$file'"
    tmux split-window -h "zathura '$file'"
    tmux select-pane -t 0
    tmux send-keys "nvim '${filename}.pdf'" C-m
  else
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

  ginit && gh repo create "$reponame" --public

  [[ ! -d .git ]] && git init

  git add .
  git commit -m "Initial commit"
  git branch -M main
  git remote add origin "git@github.com:$(gh api user --jq .login)/$reponame.git" 2>/dev/null
  git push -u origin main
}

ghcp() {
  local reponame="${1:-${PWD##*/}}"

  ginit && gh repo create "$reponame" --private 

  [[ ! -d .git ]] && git init

  git add .
  git commit -m "Initial commit"
  git branch -M main
  git remote add origin "git@github.com:$(gh api user --jq .login)/$reponame.git" 2>/dev/null
  git push -u origin main
}

function ghd() {
  local reponame="${PWD##*/}"
  gh repo delete "$reponame" --confirm
}
bindkey -s "^[s" "sudo "
bindkey -s "^[o" "xdg-open "
bindkey -s "^g" "fgit^M"

fzf_zoxide_cd() {
  local dir
  dir=$(zoxide query -l | fzf --reverse --preview="ls {}")
  [[ -n "$dir" ]] && cd "$dir"
  zle reset-prompt
}

fzf_zoxide_open() {
  local dir
  dir=$(find -type f | fzf --reverse --preview="ls {}")
  [[ -n "$dir" ]] && xdg-open "$dir"
  zle reset-prompt
}

docgo() {
  local root1 root2 pattern choice
  root1="$(go env GOMODCACHE)"
  root2="$(go env GOROOT)/src"

  choice=$(printf "functions\nmethods\nstructs\ninterfaces\ntypes" \
    | fzf --prompt="Go symbols > ") || return

  case "$choice" in
    functions)
      pattern='^\s*func\s+\K[A-Za-z_][A-Za-z0-9_]*'
      ;;
    methods)
      pattern='^\s*func\s+\([^)]+\)\s*\K[A-Za-z_][A-Za-z0-9_]*'
      ;;
    structs)
      pattern='^\s*type\s+\K[A-Za-z_][A-Za-z0-9_]*(?=\s+struct)'
      ;;
    interfaces)
      pattern='^\s*type\s+\K[A-Za-z_][A-Za-z0-9_]*(?=\s+interface)'
      ;;
    types)
      pattern='^\s*type\s+\K[A-Za-z_][A-Za-z0-9_]*'
      ;;
    *)
      return
      ;;
  esac

  rg -n --no-heading -P "$pattern" -g '*.go' "$root1" "$root2" \
  | fzf --delimiter : \
        --with-nth=3 \
        --preview 'l={2}; bat --style=numbers --color=always \
                   --highlight-line $l \
                   --line-range $((l-20)):$((l+40)) {1}' \
        --preview-window=bottom:60% \
        --bind 'enter:execute(nvim {1} +{2})'
}

docpy() {
  local root venv pyver choice pattern

  root="$(pwd)"

  # detect local .venv
  if [[ -d "$root/.venv" ]]; then
    pyver="$("$root/.venv/bin/python" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
    venv="$root/.venv/lib/python$pyver/site-packages"
  else
    venv=""
  fi

  # menu for symbol type
  choice=$(printf "functions\nclasses\nall" | fzf --prompt="Python symbols > ") || return

  case "$choice" in
    functions)
      pattern='^\s*def\s+\K[A-Za-z_][A-Za-z0-9_]*'
      ;;
    classes)
      pattern='^\s*class\s+\K[A-Za-z_][A-Za-z0-9_]*'
      ;;
    all)
      pattern='^\s*(def|class)\s+\K[A-Za-z_][A-Za-z0-9_]*'
      ;;
    *)
      return
      ;;
  esac

  # search recursively, include hidden, ignore gitignore
  rg --color=always --colors 'match:fg:yellow' --colors 'match:style:bold' \
     -n --no-heading -P "$pattern" -g '**/*.py' --hidden --no-ignore \
     "$root" ${venv:+"$venv"} \
  | awk -F: '{
      file=$1; line=$2; sym=$3;
      pkg=file;
      gsub("^.*/site-packages/","",pkg);
      gsub("^.*/","",pkg);
      # output clean tab-separated fields (no ANSI in {3})
      print sym "\t" pkg "\t" file ":" line
    }' \
  | fzf --ansi \
        --delimiter $'\t' \
        --with-nth=1,2 \
        --preview 'file_line={3}; file=${file_line%:*}; line=${file_line##*:}; bat --style=numbers --color=always --highlight-line $line --line-range $((line-10)):$((line+30)) "$file"' \
        --preview-window=bottom:50%:wrap \
        --bind 'enter:execute(
            file_line={3};
            file=${file_line%:*};
            line=${file_line##*:};
            nvim +$line "$file"
          )+abort,ctrl-p:toggle-preview'
}

zle -N fzf_zoxide_cd
zle -N fzf_zoxide_open
bindkey '^F' fzf_zoxide_cd
bindkey '^O' fzf_zoxide_open

alias glo="git log --oneline"

export CEREBRAS_API_KEY="csk-85fv2ekx4856xnp38jt82eeeyrcjwhw2n9pmd9nnkv4ftpej"
export ANDROID_HOME="$HOME/Android/Sdk/"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk/"
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH="/home/himanshu/.bun/bin:$PATH"
# use fd as default command for fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
alias vim="nvim"
alias gce="glo | fzf --preview 'git show --color=always $(echo {} | awk "{print $1}")' --bind 'ctrl-j:preview-down,ctrl-k:preview-up' --ansi"

# opencode
export PATH=/home/himanshu/.opencode/bin:$PATH
export PATH="$PATH:$(go env GOPATH)/bin"
export OPENCODE_SERVER_PASSWORD="peps1c0la"
