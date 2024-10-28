Пример запуска:
ansible-playbook --private-key AWS_keypair.pem -i hosts.ini playbook.yml

Потребуется:
ansible-galaxy collection install community.general

ansible-galaxy collection install ansible.posix

Если валится ошибка "msg": "Timeout (12s) waiting for privilege escalation prompt: "
export ANSIBLE_TIMEOUT=120;
