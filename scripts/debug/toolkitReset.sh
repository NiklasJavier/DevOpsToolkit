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
username="$3"  # Ermittelt den username des Systems
opt_data_dir="$6"  # Verzeichnis, in dem die Datei abgelegt wird
output_file="${opt_data_dir}/devopsVaultAccessSecret-${username}.yml"  # Dateiname mit username

vault_file="$4"
vault_secret="$5"
vault_startup="${opt_data_dir}/openVault.sh"  # Pfad zur zu erstellenden .sh-Datei

checkIfVaultFolderExists() {
# Überprüfen, ob das Verzeichnis existiert, falls nicht, wird es erstellt
if [ ! -d "$opt_data_dir" ]; then
    mkdir -p "$opt_data_dir"
fi
}

writeEnvironmentVariablesInBackupFile(){
cat <<EOF > "$output_file"
# !!! IMPORTANT !!! RUNTIME ENVIRONMENT VARIABLES
# This file is temporary and should not remain on your system.
# It contains sensitive runtime environment variables for $username.
# Please copy the necessary information to access the system's configurations,
# and securely delete this file immediately afterward.

vault_file: "$vault_file"
vault_secret: "$vault_secret"
EOF
echo -e "${GREY}The file ${YELLOW}$output_file ${GREY}was successfully created.${NC}"
}

writeExecutionScriptForVaultAccess(){
cat <<EOF > "$vault_startup"
#!/bin/bash
# This script opens the Vault file vault.yml with ansible-vault.
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'

if [ -f "$output_file" ]; then
  cat "$output_file"
fi

if [ ! -f "$vault_file" ]; then
  echo -e "${RED}The file ${YELLOW}"$vault_file" ${RED}was not found.${GREY}"
  exit 1
fi

ansible-vault view "$vault_file"
EOF
chmod +x "$vault_startup"
echo -e "${GREY}The script ${YELLOW}$vault_startup ${GREY}was successfully created.${NC}"
}

methods=(
checkIfVaultFolderExists
writeEnvironmentVariablesInBackupFile
writeExecutionScriptForVaultAccess
)

for method in "${methods[@]}"; do
echo -e "\n${GREY}======= ${GREEN}Running: ${PINK}[$method] ${GREY}=======${NC}"
$method 
done
