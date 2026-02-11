pkgs=$(yay -Slq | fzf -m --preview 'yay -Si {}' --preview-window=right:60%:wrap)
[ -n "$pkgs" ] && yay -S $pkgs
