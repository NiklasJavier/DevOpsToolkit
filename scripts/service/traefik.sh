#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Keine Farbe

tools_dir="$1"      # Tools-Verzeichnis

# Überprüfen, ob Docker installiert ist
if ! command -v docker &> /dev/null
then
    echo -e "${RED}Docker ist nicht installiert. Führe Installationsskript aus...${NC}"
    bash "$tools_dir/docker/install_docker.sh"
else
    echo -e "${GREEN}Docker ist bereits installiert.${NC}"
fi

echo "weiter"