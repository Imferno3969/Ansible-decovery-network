télécharger le script via internet et executer le script "setup.sh"

commande pour executer le playbook :
ansible-playbook -i hosts.ini projet/tasks/scan.yml


Post-Scriptum :

mysql_database = zabbix
mysql_user = zabbix
mysql password = 3969
mysql root password = 3969

zabbix-server port : 10051
zabbix-web port : 8080

mdp global (machine + ssh + mysql + root) :
username : root
password : 3969

mdp zabbix web :
username : Admin
password : zabbix
