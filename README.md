télécharger le script ( setup.sh ) via internet ( https://github.com/Imferno3969/SAE5.02 ) 
Une fois télécharger faite la commande suivante pour pouvoir éxécuter le script :
sudo apt install dos2unix
sudo chmod +x ~/Téléchargement/setup.sh
dos2unix ./Telechargement/setup.sh

Enfin executer le script "setup.sh" avec la commande ci-dessous :
sudo bash ./Téléchargement/setup.sh




commande pour executer le playbook :
ansible-playbook -i hosts.ini projet/tasks/scan.yml


Post-Scriptum :

mdp global (machine + ssh + mysql + root) :
username : root
password : 3969

mdp zabbix web :
username : Admin
password : zabbix


mysql_database = zabbix
mysql_user = zabbix
mysql password = 3969
mysql root password = 3969

zabbix-server port : 10051
zabbix-web port : 8080


