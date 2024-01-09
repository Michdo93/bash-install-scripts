#!/bin/bash

# Funktion, um zu prüfen, ob sudo verfügbar ist
check_sudo() {
    if command -v sudo &> /dev/null; then
        echo "sudo"
    else
        echo ""
    fi
}

# Funktion zum Ausführen von Befehlen mit oder ohne sudo
run_command() {
    local cmd="$1"
    local sudo_available="$2"

    if [ -n "$sudo_available" ]; then
        sudo $cmd
    else
        $cmd
    fi
}

cd /opt/yara-4.4.0

# Deinstallieren von YARA und zugehörigen Abhängigkeiten
run_command "make uninstall" "$sudo_available"

# Löschen der YARA-Dateien und Verzeichnisse
run_command "rm -rf /opt/yara-4.4.0" "$sudo_available"
run_command "rm /usr/lib/libyara.so" "$sudo_available"

echo "Deinstallation von YARA abgeschlossen."
