
ansibpe-pull -i localhist, -U htttps://github.com/RudrayyaMS/roboshop-ansible roboshop.yml -e role_name=${component} -e env=${env} >/opt/ansible.log