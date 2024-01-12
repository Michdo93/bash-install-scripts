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

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

python3 -m pip install jupyter notebook

mkdir -p $HOME/.jupyter
# Jupyter-Notebook-Konfigurationsdatei erstellen
jupyter notebook --generate-config
# Passwort jupyter erstellen
cat <<EOL | run_command "tee $HOME/.jupyter/jupyter_notebook_config.py"
c.NotebookApp.password = 'sha1:e0f52e6c8f2d:4012330a020e68944ac9d77b7c40f7d258c104ec'
c.NotebookApp.ip = '0.0.0.0'
EOL

# systemd-Service-Datei erstellen
cat <<EOL | run_command "tee /etc/systemd/system/jupyter-notebook.service" "$sudo_available"
[Unit]
Description=Jupyter Notebook

[Service]
Type=simple
PIDFile=/run/jupyter.pid
ExecStart=jupyter notebook --notebook-dir=$USER/.jupyter
User=$USER
Group=$USER
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL

# systemd-Service aktivieren und starten
run_command "systemctl enable jupyter-notebook.service" "$sudo_available"
run_command "systemctl start jupyter-notebook.service" "$sudo_available"
