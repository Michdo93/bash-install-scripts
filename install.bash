#!/bin/bash

# Aktuelles Verzeichnis
skriptVerzeichnis="./install"

# Arrays für die verschiedenen Skripte
vorherigeSkripte=()
ufw=()
ufw_with_ports=()
aide=()
do_release_upgrade=()

# Array mit den Namen der Skripte im Verzeichnis
skriptArray=("$skriptVerzeichnis/"*)

# Ausgabe der vorhandenen Skripte mit Markierung
echo "Verfügbare Skripte:"
for skript in "${skriptArray[@]}"; do
    markierung=" "

    # Überprüfung, ob das Skript ausgeschlossen werden soll
    if [[ "$skript" =~ .*_uninstall\.bash$ ]] || [[ "$skript" =~ .*-pwd\.bash$ ]] || [[ "$skript" =~ .*change-root-pwd\.bash$ ]] || [[ "$skript" =~ .*create-new-user\.bash$ ]] || [ "$(basename "$skript")" == "install.bash" ] || [ "$(basename "$skript")" == "README.md" ]; then
        continue
    fi
    
    echo -n "Möchten Sie $skript ausführen? (Y/n): "
    read -n 1 markierung
    echo
    if [ "$markierung" == "Y" ] || [ "$markierung" == "y" ]; then
        case "$(basename "$skript")" in
            "do-release-upgrade.bash")
                do_release_upgrade=("$skript")
                ;;
            "aide.bash")
                aide=("$skript" "${aide[@]}")
                ;;
            "ufw.bash")
                # Überprüfen, ob ufw_with_ports.bash bereits ausgewählt wurde
                if [[ ! " ${ufw_with_ports[@]} " =~ " ${skript} " ]]; then
                    ufw=("$skript" "${ufw[@]}")
                fi
                ;;
            "ufw-with-ports.bash")
                ufw_with_ports=("$skript" "${ufw_with_ports[@]}")
                # Ufw.bash aus vorherigeSkripte entfernen
                vorherigeSkripte=("${vorherigeSkripte[@]/ufw.bash}")
                ;;
            *)
                vorherigeSkripte+=("$skript")
                ;;
        esac
    fi
done

# Ausführung der ausgewählten Skripte in gewünschter Reihenfolge
for skript in "${vorherigeSkripte[@]}" "${ufw_with_ports[@]}" "${ufw[@]}" "${aide[@]}" "${do_release_upgrade[@]}"; do
    echo "Führe Skript aus: $skript"
    bash "$skript"
done
