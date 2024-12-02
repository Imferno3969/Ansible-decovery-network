executer le script "setup.sh"

mdp global (machine + ssh + mysql + ...) :
id : root
mdp : 3969

mdp zabbix web :
id : Admin
mdp : zabbix


commande pour executer le playbook :
ansible-playbook -i hosts.ini projet/tasks/scan.yml
