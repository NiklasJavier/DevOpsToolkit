# DevOpsToolkit

Das **DevOpsToolkit**-Repository bietet eine Sammlung von Skripten und Konfigurationen, um eine Entwicklungs-, Staging- oder Produktionsumgebung schnell und einfach einzurichten. Es ist flexibel und ermöglicht sowohl die Konfiguration basierend auf benutzerdefinierten Einstellungen als auch die Verwendung von Standardwerten.

## Konfiguration

Die Konfiguration erfolgt über eine Datei namens `config.temp.yaml`. Diese Datei enthält mehrere Variablen, die vom Benutzer definiert werden können, oder automatisch generierte Standardwerte.

### Variablen in `config.temp.yaml`:

- **`system_name`**:  
  Der Name des Systems oder Servers, der für die Konfiguration verwendet wird. Wenn der Benutzer keinen Namen eingibt, wird ein Standardname generiert.  
  Beispiel:  
  ```yaml
  system_name: "$SYSTEM_NAME"
  ```

- **`ssh_port`**:  
  Der SSH-Port, über den die Verbindung zum Server hergestellt wird. Standardmäßig wird Port **282** verwendet, falls der Benutzer keinen Port angibt.  
  Beispiel:  
  ```yaml
  ssh_port: "$SSH_PORT"
  ```

- **`log_level`**:  
  Das gewünschte Log-Level für die Protokollierung der Anwendung. Mögliche Optionen sind `"debug"`, `"info"`, `"warn"`, und `"error"`. Standardwert: **info**.  
  Beispiel:  
  ```yaml
  log_level: "$LOG_LEVEL"
  ```

- **`opt_data_dir`**:  
  Das Datenverzeichnis, in dem Anwendungsdaten gespeichert werden. Es basiert standardmäßig auf dem `system_name` (z.B. `/opt/$SYSTEM_NAME/data`), falls kein anderes Verzeichnis angegeben wird.  
  Beispiel:  
  ```yaml
  opt_data_dir: "$OPT_DATA_DIR"
  ```

- **`use_defaults`**:  
  Eine Flag-Variable, die angibt, ob das Skript im "Default-Modus" ausgeführt wird. Wenn `use_defaults` auf **true** gesetzt ist, werden keine Eingabeaufforderungen an den Benutzer gestellt. Stattdessen werden automatisch die Standardwerte verwendet.  
  Beispiel:  
  ```yaml
  use_defaults: "$USE_DEFAULTS"
  ```

- **`tools`**:  
  Diese Variable enthält die Liste der Tools, die installiert werden sollen. Der Benutzer kann die Tools manuell angeben (z.B. `docker ansible terraform`). Wenn keine Eingabe erfolgt oder `USE_DEFAULTS=true` ist, werden automatisch alle Standardtools ausgewählt.  
  Beispiel:  
  ```yaml
  tools: "$TOOLS"
  ```

- **`ssh_key_function_enabled`**:  
  Diese Variable gibt an, ob die SSH-Key-Funktion aktiviert ist. Wenn sie auf **false** gesetzt ist, wird die Funktion deaktiviert, außer es wird ein gültiger SSH-Schlüssel eingegeben.  
  Beispiel:  
  ```yaml
  ssh_key_function_enabled: "$SSH_KEY_FUNCTION_ENABLED"
  ```

- **`ssh_key_public`**:  
  Enthält den öffentlichen SSH-Schlüssel (Public Key), der vom Benutzer eingegeben wurde. Wenn kein Schlüssel eingegeben wird, bleibt diese Variable leer.  
  Beispiel:  
  ```yaml
  ssh_key_public: "$SSH_KEY_PUBLIC"
  ```

- **`tools_dir`**:  
  Speichert den Pfad zu dem Verzeichnis, in dem die verschiedenen Tools (z.B. Ansible, Docker, Terraform) abgelegt sind.  
  Beispiel:  
  ```yaml
  tools_dir: "$TOOLS_DIR"
  ```

- **`scripts_dir`**:  
  Speichert den Pfad zu dem Verzeichnis, in dem allgemeine Skripte abgelegt sind.  
  Beispiel:  
  ```yaml
  scripts_dir: "$SCRIPTS_DIR"
  ```

- **`pipelines_dir`**:  
  Speichert den Pfad zu dem Verzeichnis, in dem Pipeline-Konfigurationsdateien (z.B. CI/CD-Pipelines) gespeichert sind.  
  Beispiel:  
  ```yaml
  pipelines_dir: "$PIPELINES_DIR"
  ```

## Setup

Um das **DevOpsToolkit** zu installieren und zu konfigurieren, kann das folgende Skript verwendet werden. Es stehen mehrere Optionen zur Verfügung, um verschiedene Umgebungen zu konfigurieren.

### Standard-Setup

Dieses Setup verwendet die Standardwerte für alle Variablen:

```bash
curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash
```

### Setup-Optionen:

Die folgenden Befehle verwenden das **`-t`**-Flag, um die Art der Umgebung festzulegen. Das **`-key`**-Flag kann optional hinzugefügt werden, um einen öffentlichen SSH-Schlüssel bereitzustellen.

- **`-t production`**:  
  Setzt **`USE_DEFAULTS=true`** und richtet eine Produktionsumgebung ein.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash -s -- -t production
  ```

- **`-t staging`**:  
  Setzt **`USE_DEFAULTS=true`** und richtet eine Staging-Umgebung ein.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash -s -- -t staging
  ```

- **`-t dev`**:  
  Setzt **`USE_DEFAULTS=true`** und richtet eine Entwicklungsumgebung ein.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash -s -- -t dev
  ```

- **`-t dev -key "ssh-pub-key"`**:  
  Setzt **`USE_DEFAULTS=true`**, richtet eine Entwicklungsumgebung ein und aktiviert die SSH-Key-Funktion mit dem bereitgestellten öffentlichen Schlüssel.

  ```bash
  curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/get_devops_toolkit.sh | bash -s -- -t dev -key "ssh-pub-key"
  ```

## Erklärungen der Optionen

- **`-t production / staging / dev`**:  
  Diese Option legt fest, welche Umgebung eingerichtet wird. Die Option **`USE_DEFAULTS=true`** sorgt dafür, dass keine Benutzereingaben erforderlich sind und die Standardwerte verwendet werden.

- **`-key "ssh-pub-key"`**:  
  Über diese Option kann ein öffentlicher SSH-Schlüssel übergeben werden. Wenn ein Schlüssel angegeben wird, wird die SSH-Key-Funktion aktiviert und der Schlüssel dem Server hinzugefügt.