#!/usr/bin/env bash

git log \
  --pretty=format:'%H%x09%C(yellow)%h%Creset %C(cyan)%ad%Creset %C(green)%an%Creset %s' \
  --date=short \
  --color=always |
fzf \
  --ansi \
  --delimiter=$'\t' \
  --with-nth=2 \
  --preview 'git show --color=always {1} | delta' \
  --preview-window='down:70%' \
  --bind 'enter:execute(git show --color=always {1} | delta)'
