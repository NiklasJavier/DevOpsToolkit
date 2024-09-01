#!/bin/bash

# Aktuellen Benutzernamen definieren, der nicht gelöscht werden soll
currentUsername="$3"

# Farben definieren
RED='\033[0;31m'
NC='\033[0m' # Keine Farbe

# Warnung anzeigen
echo -e "${RED}WARNUNG: Dieses Skript wird alle Ports, die nicht in der SSH-Konfiguration enthalten sind, und alle Ordner, die nicht in der config.yml enthalten sind, löschen.${NC}"
echo -e "${RED}Stellen Sie sicher, dass der aktuelle Ordner in der config.yml vorhanden ist, sonst werden diese Dateien für immer gelöscht.${NC}"

# Bestätigung anfordern
read -p "Möchten Sie fortfahren? (ja/nein): " confirmation

# Überprüfen, ob der Benutzer fortfahren möchte
if [[ "$confirmation" != "ja" ]]; then
  echo "Abgebrochen. Keine Änderungen vorgenommen."
  exit 1
fi

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

# Schritt 1: Extrahiere den SSH-Port aus der Konfigurationsdatei
ssh_port=$(grep "^Port " /etc/ssh/sshd_config | awk '{print $2}')

# Falls kein Port in der Datei explizit gesetzt ist, Standardport 22 verwenden
if [ -z "$ssh_port" ]; then
  ssh_port=22
fi

echo "Der konfigurierte SSH-Port ist: $ssh_port"

# Schritt 2: Liste der geöffneten Ports mit ufw
open_ports=$(sudo ufw status numbered | grep -oP '\d+(?=/tcp)')

# Schritt 3: Entferne Regeln für nicht verwendete Ports
for port in $open_ports; do
  if [ "$port" -ne "$ssh_port" ]; then
    echo "Lösche Regel für Port $port"
    sudo ufw delete allow "$port/tcp"
  fi
done