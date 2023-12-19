#!/bin/bash
apt update
apt upgrade -y

apt install curl git wget net-tools -y

# Add Docker's official GPG key:
apt update
apt install ca-certificates curl gnupg -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

groupadd docker
usermod -aG docker $USER

systemctl start docker.service
systemctl enable docker.service
systemctl start containerd.service
systemctl enable containerd.service

# Warten, bis Docker-Dienste vollständig initialisiert sind
while ! docker info &>/dev/null; do
    sleep 1
done

docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer:lates
