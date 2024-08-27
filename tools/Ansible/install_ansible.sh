#!/bin/bash
# Farben für die Ausgabe
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Keine Farbe

# Skript zur Installation von Ansible und seinen Abhängigkeiten auf Ubuntu/Debian

# Temporären Ordner erstellen
echo -e "${GREEN}Creation of a temporary folder...${NC}"
TMP_DIR=$(mktemp -d)

echo -e "${GREEN}Update the package list and install dependencies...${NC}"
# Update der Paketliste und Installation der Voraussetzungen
sudo apt-get update
sudo apt-get install -y \
    software-properties-common 

# Hinzufügen des Ansible PPA und Installation von Ansible
echo -e "${GREEN}Adding Ansible PPA...${NC}"
sudo apt-add-repository --yes --update ppa:ansible/ansible

echo -e "${GREEN}Installing Ansible...${NC}"
sudo apt-get install -y ansible

# Prüfen, ob Ansible installiert wurde
echo -e "${GREEN}Checking if Ansible was installed successfully...${NC}"
if ansible --version > /dev/null 2>&1; then
    echo -e "${GREEN}Ansible installed successfully.${NC}"
else
    echo -e "${RED}Ansible installation failed.${NC}"
    exit 1
fi

# Nach der Nutzung wird der temporäre Ordner gelöscht
echo -e "${GREEN}Cleaning up...${NC}"
rm -rf "$TMP_DIR"
echo -e "${GREEN}Temporary directory deleted.${NC}"

echo -e "${GREEN}Script finished: Ansible installation complete.${NC}"
