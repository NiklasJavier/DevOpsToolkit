#!/bin/bash
# Farben für die Ausgabe
GREEN='\033[0;32m'
NC='\033[0m' # Keine Farbe

# Skript zur Installation von Docker und seinen Abhängigkeiten auf Ubuntu/Debian
# Temporären Ordner erstellen
echo -e "${GREEN}Creation of a temporary folder...${NC}"
TMP_DIR=$(mktemp -d)

echo -e "${GREEN}Download dependent packages...${NC}"
# Update der Paketliste und Installation der Voraussetzungen
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl 

echo -e "${GREEN}Download Docker installation script...${NC}"
curl -fsSL https://get.docker.com -o "$TMP_DIR/get-docker.sh"

# Prüfen, ob die Datei heruntergeladen wurde
echo -e "${GREEN}Check whether the file is in the Temp folder...${NC}"
if [ -f "$TMP_DIR/get-docker.sh" ]; then
    echo -e "${GREEN}Docker installation script downloaded to: $TMP_DIR/get-docker.sh ${NC}"
    echo -e "${GREEN}Installation of Docker...${NC}"
    sh "$TMP_DIR/get-docker.sh"
    # Update der Paketliste und Installation der Voraussetzungen
    echo -e "${GREEN}Installation of Docker-Compose...${NC}"
    sudo apt-get update
    sudo apt-get install -y \
    docker-compose 
else
    echo -e "${RED}Docker installation script does not exist at: $TMP_DIR/get-docker.sh ${NC}"
    echo -e "${RED}Aborting installation.${NC}"
    exit 1
fi

# Nach der Nutzung wird der Ordner gelöscht
echo -e "${GREEN}Cleaning up...${NC}"
rm -rf "$TMP_DIR"
echo -e "${GREEN}Temporary directory deleted.${NC}"

echo -e "${GREEN}Script finished: Docker installation${NC}"
