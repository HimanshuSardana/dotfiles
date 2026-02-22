todos=$(cat ~/.local/todos)
selected=$(cat ~/.local/todos | rofi -dmenu -p "TODOs")

if [[ $selected == +\ * ]]; then
    echo "${selected:2}" >> ~/.local/todos
    notify-send "Added TODO:" "${selected:2}"
else
    sed -i "/$selected/d" ~/.local/todos
    notify-send "Removed TODO:" "$selected"
fi
