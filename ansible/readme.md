Пример запуска:
ansible-playbook --private-key AWS_keypair.pem -i hosts.ini playbook.yml

Потребуется:
ansible-galaxy collection install community.general

ansible-galaxy collection install ansible.posix
