# DevOpsToolkit

## Überblick

The **DevOpsToolkit** repository provides a collection of scripts and configurations to quickly and easily set up a development, staging, or production environment. It is flexible and allows configuration based on user-defined settings or the use of default values.

## Inhaltsverzeichnis

- [Installation](#installation)
- [Verwendung](#verwendung)
- [Konfiguration](#konfiguration)
- [DevOps CLI Tool](#devops-cli-tool)
- [Verwendung der Ansible Vault](#verwendung-der-ansible-vault)
- [Debugging und Updates](#debugging-und-updates)
- [Features](#features)
- [Lizenz](#lizenz)
- [Kontakt](#kontakt)

## Installation

Das DevOpsToolkit kann über verschiedene Befehle initialisiert und installiert werden. Hier ist ein Beispiel für ein schnelles Setup.

### Beispiel für ein schnelles Setup:

Mit diesem Befehl wird das Toolkit installiert und direkt danach ein Setup-Skript ausgeführt. Dies ermöglicht ein reibungsloses und schnelles Setup.

```bash
curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/setup_devops_toolkit.sh | bash -s -- -branch dev -key "ssh-pub-key" && devops setup
```

- **curl -fsSL**: Ruft das Setup-Skript vom angegebenen GitHub-Repository ab.
- **bash -s -- -branch dev -key "ssh-pub-key"**: Führt das Skript aus, richtet eine Entwicklungsumgebung ein und aktiviert die SSH-Key-Funktion mit dem angegebenen öffentlichen Schlüssel.
- **&& devops setup**: Startet unmittelbar nach der Installation das `setup`-Skript über das `devops`-Kommando, um die Einrichtung abzuschließen. Dabei wird auch eine Ansible Vault im `${opt_data_dir}` Verzeichnis angelegt.

### Weitere Beispiel-Befehle:

- **Production Umgebung einrichten**:
  
  Dieser Befehl setzt `USE_DEFAULTS=true` und richtet eine Produktionsumgebung ein.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/setup_devops_toolkit.sh | bash -s -- -branch production
  ```

- **Staging Umgebung einrichten**:
  
  Dieser Befehl setzt `USE_DEFAULTS=true` und richtet eine Staging-Umgebung ein.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/setup_devops_toolkit.sh | bash -s -- -branch staging 
  ```

- **Development Umgebung einrichten**:
  
  Dieser Befehl setzt `USE_DEFAULTS=true` und richtet eine Entwicklungsumgebung ein.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/setup_devops_toolkit.sh | bash -s -- -branch dev
  ```

- **Development Umgebung mit SSH-Schlüssel einrichten**:
  
  Dieser Befehl setzt `USE_DEFAULTS=true`, richtet eine Entwicklungsumgebung ein und aktiviert die SSH-Schlüssel-Funktion mit dem angegebenen öffentlichen Schlüssel.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/setup_devops_toolkit.sh | bash -s -- -branch dev -key "ssh-pub-key"
  ```

### Verfügbare Flags:

- **`-branch [production|staging|dev]`**:
  - Legt den Branch fest, der verwendet wird. Diese Option aktiviert standardmäßig `USE_DEFAULTS=true` und richtet die entsprechende Umgebung ein.
  
- **`-full [true|false]`**:
  - Führt eine vollständige Installation durch, wenn auf `true` gesetzt.
  
- **`-systemname [Name]`**:
  - Setzt den Systemnamen (ehemals Hostname).
  
- **`-username [Name]`**:
  - Definiert den Benutzernamen für die Konfiguration.
  
- **`-key [Pfad]`**:
  - Aktiviert die SSH-Key-Funktion und verwendet den angegebenen öffentlichen Schlüssel.
  
- **`-port [Portnummer]`**:
  - Legt den Port für SSH-Verbindungen fest.
  
- **`-tools [Tools]`**:
  - Installiert zusätzliche Tools, die durch Leerzeichen getrennt werden.

## DevOps CLI Tool

Das DevOps CLI Tool ist ein zentraler Bestandteil des DevOpsToolkit, das die Ausführung von Automatisierungsskripten erleichtert. Nach der Installation und Initialisierung ist das Tool über das Kommando `devops` verfügbar, wodurch der Aufruf von `./devops_cli.sh` nicht mehr notwendig ist.

### Verwendung:

Nach der Initialisierung des Toolkits kann das Tool direkt über das `devops`-Kommando aufgerufen werden:

```bash
devops [foldername] <command> [args]
```

### Funktionsweise:

1. **Konfiguration laden**: Das Tool lädt eine Konfigurationsdatei, die vorab definiert oder durch den Benutzer angepasst wurde. Diese Datei enthält Schlüssel-Wert-Paare, die als Umgebungsvariablen im Skript verfügbar gemacht werden.

2. **Befehlslogging**: Alle ausgeführten Befehle werden mit Zeitstempel und Benutzername in einer Logdatei (`$LOG_FILE`) protokolliert.

3. **Befehlsausführung**: Basierend auf dem angegebenen Befehl sucht das Tool im Skriptverzeichnis (`$SCRIPTS_DIR`) nach dem entsprechenden Skript und führt es mit den notwendigen Argumenten und Umgebungsvariablen aus.

4. **Hilfe anzeigen**: Wird `help` als Befehl angegeben, zeigt das Tool eine Liste aller verfügbaren Skripte und Befehle an. Es kann auch spezifische Hilfestellungen für einzelne Befehle anzeigen.

### Beispiel:

```bash
devops debug update
```

Wenn `deploy` ein Ordner im Skriptverzeichnis ist und `myapp.sh` ein Skript darin, wird dieses Skript mit den angegebenen Argumenten ausgeführt.

### Fehlerbehandlung:

Falls ein Befehl nicht gefunden oder nicht erfolgreich ausgeführt wird, zeigt das Tool eine Fehlermeldung an und bietet die Möglichkeit, einen Standardbefehl (`$default_command`) auszuführen.

## Verwendung der Ansible Vault

Das DevOpsToolkit verwendet eine verschlüsselte Ansible Vault, um vertrauliche und dynamisch konfigurierbare Parameter sicher zu speichern und zu verwalten. Bei der Ausführung des `devops setup`-Befehls wird eine Vault-Datei im `${opt_data_dir}` Verzeichnis angelegt, die sensible Daten wie Zugangsdaten und Konfigurationsparameter enthält.

### Verwaltung der Vault:

- **Vault-Inhalt anzeigen und bearbeiten**: Der Inhalt der Vault kann über das `devops vault` Kommando eingesehen und bearbeitet werden.
- **Vault-Schlüssel**: Der geheime Schlüssel zur Entschlüsselung der Vault-Datei wird in der Variable `$VAULT_SECRET` gespeichert. Dieser Schlüssel wird nur dann im `${opt_data_dir}` Verzeichnis unter dem Namen `devopsVaultAccessSecret-${username}.yml` abgelegt, wenn eine saubere Entfernung des Toolkits über `devops debug delete` durchgeführt wird. Es wird empfohlen, diesen Schlüssel sicher zu notieren und die Datei nach dem Setup zu löschen.

### Beispiel für die Verwaltung der Vault:

- **Vault anzeigen**:
  ```bash
  devops vault
  ```

- **Vault öffnen mit gespeichertem Schlüssel**:
  Ein Skript namens `openVault.sh` im `${opt_data_dir}` Verzeichnis ermöglicht es, die Vault mit dem gespeicherten Schlüssel zu öffnen:
  ```bash
  ${opt_data_dir}/openVault.sh
  ```

  Dies stellt sicher, dass die durch das Skript eingerichteten Systeme weiterhin Zugriff auf die notwendigen Konfigurationsparameter haben, selbst wenn der Schlüssel aus dem System entfernt wird. Es wird jedoch empfohlen, den Zugangsschlüssel zu löschen, um die Sicherheit zu gewährleisten.

## Debugging und Updates

Das DevOpsToolkit enthält Funktionen für die Fehlerbehebung und Aktualisierung. Über das `devops update` Kommando können die neuesten Änderungen an den Skripten bezogen werden, während eigene Änderungen und Ergänzungen bestehen bleiben.

### Funktionen des Debugging und der Updates:

- **Toolkit-Bereinigung**: Entfernt alle temporären Dateien, Konfigurationen und Zugangsdaten aus dem System, außer einer Sicherungskopie der Zugangsdaten, die im `${opt_data_dir}` als `.yml` abgelegt wird. Der Vault-Schlüssel wird nur abgelegt, wenn `devops debug delete` ausgeführt wird.
  
- **Toolkit-Updates**: Mit dem Befehl `devops update` können die neuesten Änderungen an den Skripten bezogen werden, während eigene Anpassungen erhalten bleiben. Dies stellt sicher, dass das Toolkit immer auf dem neuesten Stand ist.

### Beispiel:

- **Toolkit bereinigen**:
  ```bash
  devops debug delete
  ```

- **Toolkit aktualisieren**:
  ```bash
  devops update
  ```

Dieses Skript aktualisiert das Toolkit und stellt sicher, dass alle Komponenten auf dem neuesten Stand sind, während eigene Anpassungen erhalten bleiben.

## Features

- **Automatisierte Skripterkennung und -ausführung**: Durchsucht das Skriptverzeichnis nach ausführbaren Dateien und führt diese basierend auf der Benutzeranweisung aus.
- **Konfigurierbare Umgebungsvariablen**: Lädt und setzt Variablen aus einer Konfigurationsdatei, um Skripte dynamisch anzupassen.
- **Integriertes Logging**: Protokolliert alle ausgeführten Befehle für eine spätere Überprüfung.
- **Sicheres Vault-Management**: Verwaltung von vertraulichen Daten über eine verschlüsselte Ansible Vault, mit der Möglichkeit, den Zugangsschlüssel sicher zu löschen oder zu sichern.
- **Debugging und Updates**: Enthält Werkzeuge zur Bereinigung und Aktualisierung des Toolkits, während eine sichere Kopie der Zugangsdaten erhalten bleibt. Änderungen an Skripten können über `devops update` bezogen werden, ohne dass eigene Anpassungen verloren gehen.
- **Einfacher Zugriff über `devops`**: Nach der Installation kann das CLI-Tool direkt über das Kommando `devops` genutzt werden, ohne den Pfad explizit angeben zu müssen.

## Lizenz

Dieses Projekt steht unter der [Lizenztyp] Lizenz.

## Kontakt

Bei Fragen oder für Unterstützung können Sie uns unter [Kontaktinformation] erreichen.