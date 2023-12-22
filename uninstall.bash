#!/bin/bash

# Aktuelles Verzeichnis
skriptVerzeichnis="./uninstall"

# Arrays für die verschiedenen Skripte
vorherigeSkripte=()
ufw=()
ufw_with_ports=()
aide=()
do_release_upgrade=()

# Funktion zum Hinzufügen von Skripten zu einem Array unter Berücksichtigung bestimmter Bedingungen
add_script() {
    local script="$1"
    
    case "$(basename "$script")" in
        "do-release-upgrade.bash")
            do_release_upgrade=("$script")
            ;;
        "aide.bash")
            aide=("$script" "${aide[@]}")
            ;;
        "ufw.bash")
            # Überprüfen, ob ufw_with_ports.bash bereits ausgewählt wurde
            if [[ ! " ${ufw_with_ports[@]} " =~ " ${skript} " ]]; then
                ufw=("$script" "${ufw[@]}")
            fi
            ;;
        "ufw-with-ports.bash")
            ufw_with_ports=("$script" "${ufw_with_ports[@]}")
            # Ufw.bash aus vorherigeSkripte entfernen
            vorherigeSkripte=("${vorherigeSkripte[@]/ufw.bash}")
            ;;
        *)
            vorherigeSkripte+=("$script")
            ;;
    esac
}

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
        add_script "$skript"
    fi
done

# Überprüfen der Bedingungen und Anpassen der Skriptreihenfolge
# Wenn docker.bash, emulatorjs.bash, homer.bash oder portainer.bash ausgeführt wurde, dann soll docker.bash als letztes ausgeführt werden
if [[ " ${vorherigeSkripte[@]} " =~ " docker.bash " ]] || [[ " ${vorherigeSkripte[@]} " =~ " emulatorjs.bash " ]] || [[ " ${vorherigeSkripte[@]} " =~ " homer.bash " ]] || [[ " ${vorherigeSkripte[@]} " =~ " portainer.bash " ]]; then
    add_script "${vorherigeSkripte[@]}"
    vorherigeSkripte=()
fi

# Wenn mariadb.bash ausgeführt wurde, dann soll es nach owncloud.bash, nextcloud.bash und icinga2.bash ausgeführt werden
if [[ " ${vorherigeSkripte[@]} " =~ " mariadb.bash " ]]; then
    add_script "${vorherigeSkripte[@]}"
    vorherigeSkripte=()
fi

# Wenn influxdb2.bash ausgeführt wurde, dann soll es nach speedtest.bash ausgeführt werden
if [[ " ${vorherigeSkripte[@]} " =~ " influxdb2.bash " ]]; then
    add_script "${vorherigeSkripte[@]}"
    vorherigeSkripte=()
fi

# Ausführung der ausgewählten Skripte in gewünschter Reihenfolge
for skript in "${ufw_with_ports[@]}" "${ufw[@]}" "${aide[@]}" "${do_release_upgrade[@]}"; do
    echo "Führe Skript aus: $skript"
    bash "$skript"
done
