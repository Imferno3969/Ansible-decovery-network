#!/bin/bash

# Mise à jour des paquets
echo "Mise à jour des paquets d'Ubuntu..."
sudo apt update 

echo

# Installation des paquets nécessaires pour Docker
echo "Installation des paquets nécessaires pour Docker..."
sudo apt install -y ca-certificates curl gnupg lsb-release 

echo

# Ajout de la clé GPG pour vérifier les paquets Docker téléchargés
echo "Ajout de la clé GPG pour Docker..."
sudo mkdir -p /etc/apt/keyrings 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo

# Ajout du dépôt Docker à la liste des sources
echo "Ajout du dépôt Docker aux sources..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo

# Mise à jour des paquets disponibles
echo "Mise à jour des paquets disponibles..."
sudo apt update

echo

# Installation de Docker
echo "Installation de Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io

echo

# Création d'un réseau Docker isolé
echo "Création d'un réseau Docker isolé..."
sudo docker network create \
  --driver bridge \
  --internal \
  private_network

echo

# Création d'un réseau temporaire pour accès internet
echo "Création d'un réseau temporaire pour accès Internet..."
sudo docker network create \
  --driver bridge \
  temporary_network

echo

# Vérification de la création des réseaux
echo "Liste des réseaux Docker..."
sudo docker network list

echo

# Création des conteneurs Ubuntu
echo "Création des conteneurs Ubuntu..."
sudo docker run -dit --name container1 --network temporary_network ubuntu
sudo docker run -dit --name container2 --network temporary_network ubuntu

echo

# Création du conteneur MySQL Server
echo "Création du conteneur MySQL Server..."
sudo docker run --name mysql-server -t \
             -e MYSQL_DATABASE="zabbix" \
             -e MYSQL_USER="zabbix" \
             -e MYSQL_PASSWORD="3969" \
             -e MYSQL_ROOT_PASSWORD="3969" \
             --network=temporary_network \
             --restart unless-stopped \
             -d mysql:8.0-oracle \
             --character-set-server=utf8 --collation-server=utf8_bin \
             --default-authentication-plugin=mysql_native_password

echo

# Création du conteneur Zabbix Server
echo "Création du conteneur Zabbix Server..."
sudo docker run --name zabbix-server \
             -e DB_SERVER_HOST="mysql-server" \
             -e MYSQL_DATABASE="zabbix" \
             -e MYSQL_USER="zabbix" \
             -e MYSQL_PASSWORD="3969" \
             -e MYSQL_ROOT_PASSWORD="3969" \
             --network=temporary_network \
             -p 10051:10051 \
             --restart unless-stopped \
             -d zabbix/zabbix-server-mysql:alpine-7.0-latest

echo

# Création du conteneur Zabbix Web
echo "Création du conteneur Zabbix Web..."
sudo docker run --name zabbix-web \
             -e DB_SERVER_HOST="mysql-server" \
             -e MYSQL_DATABASE="zabbix" \
             -e MYSQL_USER="zabbix" \
             -e MYSQL_PASSWORD="3969" \
             -e MYSQL_ROOT_PASSWORD="3969" \
             -e ZBX_SERVER_HOST="zabbix-server" \
             -e PHP_TZ="Europe/Paris" \
             --network=temporary_network \
             -p 80:8080 \
             --restart unless-stopped \
             -d zabbix/zabbix-web-apache-mysql:alpine-7.0-latest

echo

#Verification creation conteneur
echo "Verification creation conteneur..."
sudo docker ps

echo

# Configuration du conteneur 1
echo "Configuration du conteneur 1..."
sudo docker exec container1 bash -c "
apt update && 
apt install -y net-tools iputils-ping nano iproute2 openssh-server &&
service ssh start &&
echo 'root:3969' | chpasswd &&
rm /etc/ssh/sshd_config &&
cat > /etc/ssh/sshd_config <<EOF
Include /etc/ssh/sshd_config.d/*.conf
PasswordAuthentication yes
PermitRootLogin yes
KbdInteractiveAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem    sftp    /usr/lib/openssh/sftp-server
EOF"


echo

# Installation d'Ansible dans le conteneur 1
echo "Installation d'Ansible dans le conteneur 1..."
sudo docker exec container1 bash -c "
apt install -y ansible python3-pip python3-venv &&
python3 -m venv ~/myenv &&
source ~/myenv/bin/activate &&
apt install -y tree git &&
git clone https://github.com/Imferno3969/SAE5.02.git &&
mv SAE5.02/projet/ / &&
rm -rf SAE5.02 &&
tree projet/
"

echo

# Configuration du conteneur 2
echo "Configuration du conteneur 2..."
sudo docker exec container2 bash -c "
apt update &&
apt install -y net-tools iputils-ping nano iproute2 openssh-server &&
service ssh start &&
echo 'root:3969' | chpasswd &&
rm /etc/ssh/sshd_config &&
cat > /etc/ssh/sshd_config <<EOF
Include /etc/ssh/sshd_config.d/*.conf
PasswordAuthentication yes
PermitRootLogin yes
KbdInteractiveAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem    sftp    /usr/lib/openssh/sftp-server
EOF
"

echo

echo

# Configuration clé ssh entre container1 et container2 
echo "Configuration clé SSH entre container1 et container2..."
sudo docker exec container1 bash -c "
ssh-keygen &&
ssh-copy-id root@172.19.0.3
"

echo

# deconnexion du temporary_network 
echo "deconnexion du temporary_network..."
docker network disconnect temporary_network container1
docker network disconnect temporary_network container2
docker network disconnect temporary_network mysql-server
docker network disconnect temporary_network zabbix-server
docker network disconnect temporary_network zabbix-web

echo

# connexion au private_network 
echo "connexion au private_network..."
docker network connect private_network container1
docker network connect private_network container2
docker network connect private_network mysql-server
docker network connect private_network zabbix-server
docker network connect private_network zabbix-web

echo

# connexion du conteneur 2 a internet par le bridge 
echo "connexion du conteneur 2 a internet par le bridge..."
docker network connect bridge container2 

echo

# suppression de temporary_network
echo "suppression de temporary_network..."
docker network rm temporary_network

echo

echo "Script terminé avec succès !"
exit 0
