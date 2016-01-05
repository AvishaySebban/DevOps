eval `ssh-agent -s` > /dev/null
ssh-add /tmp/ntm-ansible/server.pem
ansible-playbook -i /tmp/ntm-ansible/ntm-hosts /tmp/ntm-ansible/ntm-monitoring.yml -vvvv
