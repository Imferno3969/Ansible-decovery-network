Télécharger le script ( setup.sh ) via internet ( https://github.com/Imferno3969/SAE5.02 ) 
Une fois télécharger faite les commandes suivante pour pouvoir éxécuter le script :
- sudo apt install dos2unix
- sudo chmod +x ./Téléchargement/setup.sh
- dos2unix ./Telechargement/setup.sh

Enfin executer le script "setup.sh" avec la commande ci-dessous :
- sudo bash ./Téléchargement/setup.sh


Une fois le script finit d'éxecuter, il faut :
- aller dans le container2 et redemarrer le service ssh :
  - sudo docker exec -it container2 bash
  - service ssh restart

- aller dans le container1 et faire les commandes suivantes :
  - sudo docker exec -it container1 bash
  - source ~/myenv/bin/activate
  - ssh-keygen (tout valider sans rien écrire)
  - ssh-copy-id 172.18.0.3
  - service ssh restart


Une fois cela fait, pour executer le playbook il vous suffit de taper la commande suivante  :
- ansible-playbook -i projet/hosts.ini projet/tasks/scan.yml

Une fois cela fait, vous avez plus qu'à aller dans zabbix sur le web pour voir les hotes qui ont été ajouté

Post-Scriptum :

mdp global (machine + ssh + mysql + root) :
- username : root
- password : 3969

mdp zabbix web :
- username : Admin
- password : zabbix

Paramètres :
- mysql_database = zabbix
- mysql_user = zabbix
- mysql password = 3969
- mysql root password = 3969

- zabbix-server port : 10051
- zabbix-web port : 8080


