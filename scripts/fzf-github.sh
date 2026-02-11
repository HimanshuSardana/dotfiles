#!/bin/bash

# if no arguments
if [ $# -eq 0 ]; then
    read -p "Enter GitHub username: " username
fi
username=${1:-$username}

curl -s "https://api.github.com/users/$username/repos?per_page=100" \
    | jq -r '.[].full_name' \
    | fzf \
    --preview '
        curl -s https://api.github.com/repos/{}/readme \
            | jq -r .content \
            | base64 --decode 2>/dev/null \
            | bat -l markdown --style=plain --color=always
    ' \
    --bind 'ctrl-e:execute(
        curl -s https://api.github.com/repos/{}/readme \
            | jq -r .content \
            | base64 --decode 2>/dev/null \
            | ${EDITOR:-vim} -
    )' \
    --bind 'ctrl-l:execute-silent(echo "git@github.com:{}.git" | tr -d "\"" | xclip -selection clipboard)' \
    --bind 'ctrl-o:execute(repo=$(echo {} | tr -d "\""); xdg-open "https://github.com/$repo")'
