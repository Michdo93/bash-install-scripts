#!/bin/bash

# Aktuelles Verzeichnis
skriptVerzeichnis="."

# Array mit den Namen der Skripte im Verzeichnis
skriptArray=("$skriptVerzeichnis/"*)

# Ausgabe der vorhandenen Skripte
echo "Verfügbare Skripte:"
for skript in "${skriptArray[@]}"; do
    echo "$(basename "$skript")"
done

# Array für ausgewählte Skripte
ausgewaehlteSkripte=()

# Interaktive Auswahl der Skripte
while true; do
    read -p "Welches Skript soll ausgeführt werden? (q zum Beenden): " auswahl
    if [ "$auswahl" == "q" ]; then
        break
    fi
    if [[ " ${skriptArray[@]} " =~ " ${skriptVerzeichnis}/$auswahl " ]]; then
        ausgewaehlteSkripte+=("$auswahl")
    else
        echo "Ungültige Auswahl. Bitte erneut eingeben."
    fi
done

# Ausführung der ausgewählten Skripte
for skript in "${ausgewaehlteSkripte[@]}"; do
    echo "Führe Skript aus: $skript"
    bash "$skript"
done
