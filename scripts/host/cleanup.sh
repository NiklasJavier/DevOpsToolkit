#!/bin/bash

# Aktuellen Benutzernamen definieren, der nicht gelöscht werden soll
currentUsername="$3"

# Leere Liste zur Speicherung der zu löschenden Benutzer
user_list=()

# Finde alle Verzeichnisse in /home mit genau 11 Großbuchstaben
find /home -regextype posix-extended -maxdepth 1 -mindepth 1 -type d -regex '.*/[A-Z]{11}' | while read -r dir; do
  username=$(basename "$dir")
  echo "Extrahierter Benutzername: $username"
  
  # Füge den Benutzernamen zur Liste hinzu, falls er nicht der currentUsername ist
  if [ "$username" != "$currentUsername" ]; then
    user_list+=("$username")
    echo "$username wurde der Liste hinzugefügt."
  else
    echo "Benutzer $username wird nicht zur Liste hinzugefügt, da er der aktuelle Benutzer ist."
  fi
done

# Debug-Ausgabe der Liste der zu löschenden Benutzer
echo "Benutzer, die gelöscht werden sollen:"
for username in "${user_list[@]}"; do
  echo "$username"
done

# Benutzer und ihre Verzeichnisse löschen
for username in "${user_list[@]}"; do
  echo "Lösche Benutzer: $username"
  
  # Benutzer löschen (auskommentiert für den Testlauf)
  # sudo userdel -r "$username"
  
  # Verzeichnis in /opt/SRV-* löschen, wenn es existiert
  srv_dir="/opt/SRV-$username"
  if [ -d "$srv_dir" ]; then
    echo "Lösche Verzeichnis: $srv_dir"
    # sudo rm -rf "$srv_dir"
  fi

  # Verzeichnis in /home/* löschen, wenn es existiert
  home_dir="/home/$username"
  if [ -d "$home_dir" ]; then
    echo "Lösche Verzeichnis: $home_dir"
    # sudo rm -rf "$home_dir"
  fi
done
