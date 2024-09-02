#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
PINK='\033[0;35m'
GREY='\033[1;90m'
YELLOW='\033[1;33m' 
NC='\033[0m' # Keine Farbe

# Zuweisung der Argumente zu Variablen
vault_file=$4 # Pfad zur Vault-Datei
vault_secret=$5 # Vault-Passwort

checkIfVaultExists(){
if [ ! -f "$vault_file" ]; then
  echo -e "${RED}The Vault file ${YELLOW}$vault_file ${RED}does not exist.${NC}"
  exit 1
  else 
  echo -e "${GREY}The Vault file ${YELLOW}$vault_file ${GREY}exists.${NC}"
fi
}

createTemporaryAccessFile(){
PASS_FILE=$(mktemp)
echo "$vault_secret" > "$PASS_FILE"
echo "temp_file: $PASS_FILE"
chmod 600 "$PASS_FILE"
}

openVault(){
ansible-vault edit --vault-password-file="$PASS_FILE" "$vault_file"
}

deleteTemporaryAccessFile(){
rm -f "$PASS_FILE"
}

methods=(
checkIfVaultExists
createTemporaryAccessFile
openVault
deleteTemporaryAccessFile
)

for method in "${methods[@]}"; do
echo -e "\n${GREY}======= ${GREEN}Running: ${PINK}[$method] ${GREY}=======${NC}"
$method 
done
