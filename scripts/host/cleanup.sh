#!/bin/bash

# Aktuellen Benutzernamen definieren, der nicht gelöscht werden soll
currentUsername="$3"

# Finde alle Verzeichnisse in /home mit genau 11 Großbuchstaben
find /home -regextype posix-extended -maxdepth 1 -mindepth 1 -type d -regex '.*/[A-Z]{11}' | while read -r dir; do
  username=$(basename "$dir")
  echo "Extrahierter Benutzername: $username"
  
  # Füge den Benutzernamen zur Liste hinzu, falls er nicht der currentUsername ist
  if [ "$username" != "$currentUsername" ]; then
    user_list+=("$username")
    echo "$username wird gelöscht"
    srv_dir="/opt/SRV-$username"
    home_dir="/home/$username"
    sudo userdel -r "$username"
    sudo rm -rf "$srv_dir"
    sudo rm -rf "$home_dir"
  else
    echo "Benutzer $username kann nicht gelöscht werden. Befindet sich in der config.yml"
  fi
done