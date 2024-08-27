# Ansible Local Setup

Dieser Ordner stellt eine Ansible-Konfiguration bereit, die für die lokale Einrichtung und Verwaltung des eigenen Hosts verwendet wird. Es beinhaltet Playbooks, Rollen und Variablen, um die Automatisierung von Aufgaben auf dem **localhost** zu vereinfachen.

## Ordnerstruktur

```bash
ansible_local/
├── ansible.cfg                # Ansible-Konfigurationsdatei
├── hosts.ini                  # Inventar-Datei für localhost
├── playbooks/                 # Verzeichnis für Ansible-Playbooks
│   └── local_setup.yml        # Beispiel-Playbook für die lokale Konfiguration
├── roles/                     # Verzeichnis für Rollen (zur besseren Strukturierung)
│   ├── common/                # Rolle für allgemeine Aufgaben
│   │   └── tasks/             
│   │       └── main.yml       # Aufgaben, die auf localhost ausgeführt werden
│   ├── apache/                # Rolle für Apache-Installation und -Konfiguration
│   │   ├── tasks/             
│   │   │   └── main.yml       # Aufgaben für Apache-Installation
│   │   └── handlers/
│   │       └── main.yml       # Handlers für das Neustarten von Apache
└── group_vars/                # Verzeichnis für Variablen für Gruppen (optional)
    └── local.yml              # Variablen für localhost
