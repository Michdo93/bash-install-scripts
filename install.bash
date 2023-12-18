#!/bin/bash

# Aktuelles Verzeichnis
skriptVerzeichnis="."

# Array mit den Namen der Skripte im Verzeichnis
skriptArray=("$skriptVerzeichnis/"*)

# Ausgabe der vorhandenen Skripte mit Markierung
echo "Verfügbare Skripte:"
for skript in "${skriptArray[@]}"; do
    markierung=" "

    # Überprüfung, ob das Skript ausgeschlossen werden soll
    if [[ "$skript" =~ .*_root\.bash$ ]] || [ "$(basename "$skript")" == "install.bash" ] || [ "$(basename "$skript")" == "README.md" ]; then
        continue
    fi
    
    echo -n "Möchten Sie $skript ausführen? (Y/n): "
    read -n 1 markierung
    echo
    if [ "$markierung" == "Y" ] || [ "$markierung" == "y" ]; then
        ausgewaehlteSkripte+=("$skript")
    fi
done

# Ausführung der ausgewählten Skripte
for skript in "${ausgewaehlteSkripte[@]}"; do
    echo "Führe Skript aus: $skript"
    bash "$skript"
done
