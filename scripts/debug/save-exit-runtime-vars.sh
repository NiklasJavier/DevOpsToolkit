#!/bin/bash

# Variablen definieren
username="$3"  # Ermittelt den username des Systems
opt_data_dir="$6"  # Verzeichnis, in dem die Datei abgelegt wird

output_file="${opt_data_dir}/NOT-SECURE-EXIT-${username}.yml"  # Dateiname mit username

vault_file="$4"
vault_secret="$5"

vault_startup="${opt_data_dir}/enter_vault.sh"  # Pfad zur zu erstellenden .sh-Datei

# Überprüfen, ob das Verzeichnis existiert, falls nicht, wird es erstellt
if [ ! -d "$opt_data_dir" ]; then
    mkdir -p "$opt_data_dir"
fi

# Datei erstellen und Variablen mit Erklärungen schreiben
cat <<EOF > "$output_file"


# !!! IMPORTANT !!! RUNTIME ENVIRONMENT VARIABLES
# This file should not be on your system.
# This file contains the runtime environment variables for $username.
# Please copy the information to get access to the existing configurations of the system
# and delete this file afterwards.

vault_file: "$vault_file"
vault_secret: "$vault_secret"


EOF

# Erfolgsmeldung
echo "The file $output_file was successfully created."


# Erstellt ein Skript, das den Vault mit ansible-vault öffnet
cat <<EOF > "$vault_startup"
#!/bin/bash
# This script opens the Vault file vault.yml with ansible-vault.

if [ ! -f "$vault_file" ]; then
  echo "The file vault.yml was not found."
  exit 1
fi

ansible-vault view "$vault_file"
EOF

# Macht das enter_vault.sh-Skript ausführbar
chmod +x "$vault_startup"

# Erfolgsmeldung für das Vault-Skript
echo "The script $vault_startup was successfully created."
