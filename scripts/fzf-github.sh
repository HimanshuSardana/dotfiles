# if no arguments
if [ $# -eq 0 ]; then
	read -p "Enter GitHub username: " username
fi
username=${1:-$username}
curl -s "https://api.github.com/users/$username/repos" \
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
		)'

		--preview-window=right:70%:wrap

