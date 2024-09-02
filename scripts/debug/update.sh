#!/bin/bash

# Verzeichnis des geclonten Repositories (hier anpassen)
REPO_DIR="$1/.."    # 
BRANCH_NAME="dev"  # 

# In das Verzeichnis des Repos wechseln
cd "$REPO_DIR" || { echo "Fehler: Konnte das Verzeichnis $REPO_DIR nicht finden."; exit 1; }

# Überprüfe den aktuellen Status
echo "Überprüfe den aktuellen Status des Repositories..."
git status

# Sicherstellen, dass alle Änderungen committet sind
echo "Committing alle Änderungen..."
git add .
git commit -ma "Speichere meine Änderungen" || echo "Keine Änderungen zu committen."

# Hole die neuesten Änderungen vom Remote-Repository
echo "Hole die neuesten Änderungen vom Remote-Repository..."
git fetch origin

# Rebase auf die neuesten Änderungen
echo "Führe rebase auf die neuesten Änderungen durch..."
git rebase "origin/$BRANCH_NAME"

# Überprüfe auf Konflikte
if [ $? -ne 0 ]; then
  echo "Konflikte während des Rebases entdeckt. Bitte behebe die Konflikte und fahre dann fort."
  exit 1
fi

echo "Rebase erfolgreich abgeschlossen."