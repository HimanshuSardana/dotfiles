#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
URL="$1"
TITLE=$(curl -s "$URL" | python3 -c "import sys; import re; m = re.search(r'<title>(.*?)</title>', sys.stdin.read(), re.IGNORECASE | re.DOTALL); print(m.group(1).split('–')[0].strip().replace(' ', '-').replace('/', '-')[:50] if m else '')")
[ -z "$TITLE" ] && TITLE="output"
percollate pdf --style "/home/himanshu/dotfiles/scripts/tufte.css" "$URL" -o "${TITLE}.pdf"
