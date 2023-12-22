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
        sudo "$cmd"
    else
        "$cmd"
    fi
}

# Deinstalliere ROS
echo "[Deinstalliere ROS]"

# Deinstalliere ROS-Pakete
run_command "apt-get remove --auto-remove ros-kinetic-desktop-full" "$sudo_available"

# Entferne ROS-Repository-Eintrag
run_command "rm /etc/apt/sources.list.d/ros-latest.list" "$sudo_available"

# Entferne ROS-Schlüssel
run_command "apt-key del 421C365BD9FF1F717815A3895523BAEEB01FA116" "$sudo_available"

# Deinitialisiere rosdep
run_command "rm -rf /etc/ros/rosdep/sources.list.d/20-default.list" "$sudo_available"
run_command "rosdep init" "$sudo_available"

# Deinstalliere catkin Workspace
echo "[Deinstalliere catkin Workspace]"

# Entferne catkin Workspace-Verzeichnis
run_command "rm -rf $HOME/catkin_ws" "$sudo_available"

# Entferne ROS-Einstellungen von .bashrc
echo "[Entferne ROS-Einstellungen von .bashrc]"

# Entferne ROS-Setup-Einträge von .bashrc
run_command "sed -i '/source \/opt\/ros\/kinetic\/setup.bash/d' $HOME/.bashrc" "$sudo_available"
run_command "sed -i '/source ~\/catkin_ws\/devel\/setup.bash/d' $HOME/.bashrc" "$sudo_available"
run_command "sed -i '/export ROS_MASTER_URI/d' $HOME/.bashrc" "$sudo_available"
run_command "sed -i '/export ROS_HOSTNAME/d' $HOME/.bashrc" "$sudo_available"

# Entferne ROS-Aliases von .bashrc
run_command "sed -i '/alias eb=/d' $HOME/.bashrc" "$sudo_available"
run_command "sed -i '/alias sb=/d' $HOME/.bashrc" "$sudo_available"
run_command "sed -i '/alias gs=/d' $HOME/.bashrc" "$sudo_available"
run_command "sed -i '/alias gp=/d' $HOME/.bashrc" "$sudo_available"
run_command "sed -i '/alias cw=/d' $HOME/.bashrc" "$sudo_available"
run_command "sed -i '/alias cs=/d' $HOME/.bashrc" "$sudo_available"
run_command "sed -i '/alias cm=/d' $HOME/.bashrc" "$sudo_available"

echo "[ROS wurde erfolgreich deinstalliert.]"
