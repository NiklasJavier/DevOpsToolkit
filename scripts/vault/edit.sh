#!/bin/bash

# Zuweisung der Argumente zu Variablen
vault_file=$4 # Pfad zur Vault-Datei
vault_secret=$5 # Vault-Passwort

# Überprüfen, ob die Vault-Datei existiert
if [ ! -f "$vault_file" ]; then
  echo "Fehler: Die Vault-Datei $vault_file existiert nicht."
  exit 1
fi

# Erstelle eine temporäre Datei für das Passwort
PASS_FILE=$(mktemp)
echo "$vault_secret" > "$PASS_FILE"
chmod 600 "$PASS_FILE"

# Öffne und bearbeite die Vault-Datei
ansible-vault edit --vault-password-file="$PASS_FILE" "$vault_file"

# Lösche die temporäre Passwortdatei
rm -f "$PASS_FILE"
