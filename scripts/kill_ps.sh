#!/bin/bash

# Use fzf to select a process to kill
pid=$(ps aux | fzf --preview "echo {}" | awk '{print $2}')

if [[ -z "$pid" ]]; then
  echo "No process selected. Exiting..."
  exit 1
fi

# Confirm with the user before killing
echo "Are you sure you want to kill process $pid? (y/N)"
read -r confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  kill -9 "$pid" && echo "Process $pid killed successfully." || echo "Failed to kill process $pid."
else
  echo "Process kill cancelled."
fi
