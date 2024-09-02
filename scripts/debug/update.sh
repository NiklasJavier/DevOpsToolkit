#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m' 
BLUE='\033[0;34m' 
PINK='\033[0;35m'
BOLD='\033[1m'
GREY='\033[1;90m'
NC='\033[0m' # Keine Farbe

# Variablen definieren
clone_dir="$7"
branch="$10"

gitOpenLocalRepository() {
  echo -e "${GREY}Current branch: ${YELLOW}$branch${NC}"
  echo -e "${GREY}Current directory: ${YELLOW}$clone_dir${NC}"
  cd "$clone_dir" || { echo "Fehler: Konnte das Verzeichnis $clone_dir nicht finden."; exit 1; }
}

gitFetchAddedContent() {
  echo -e "${GREY}Fetching added content...${NC}"
  git fetch
}

gitPullNewContentFromBranch() {
  echo -e "${GREY}Pulling new content from branch...${NC}"
  git pull
}

gitStatusOutput() {
  echo -e "${GREY}Checking status of the repository...${NC}"
  git status
}

methods=(
gitOpenLocalRepository
gitFetchAddedContent
gitPullNewContentFromBranch
gitStatusOutput
)

for method in "${methods[@]}"; do
echo -e "\n${GREY}======= ${GREEN}Running: ${PINK}[$method] ${GREY}=======${NC}"
$method 
done
