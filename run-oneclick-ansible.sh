#!/bin/bash

set -e

echo "--------------------------------------"
echo "1) Reading Terraform outputs"
echo "--------------------------------------"

# Read outputs
BASTION_IP=$(terraform -chdir=terraform output -raw bastion_ip)
PRIMARY_IP=$(terraform -chdir=terraform output -raw primary_db_ip)
REPLICA_IP=$(terraform -chdir=terraform output -raw replica_db_ip)

echo "Bastion: $BASTION_IP"
echo "Primary: $PRIMARY_IP"
echo "Replica: $REPLICA_IP"

echo "--------------------------------------"
echo "2) Creating hosts.ini automatically"
echo "--------------------------------------"

cat > ansible/hosts.ini <<EOF
[db]
primary ansible_host=$PRIMARY_IP
replica ansible_host=$REPLICA_IP

[bastion]
bastion ansible_host=$BASTION_IP

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/jenkins.pem
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -i /var/lib/jenkins/.ssh/jenkins.pem ubuntu@13.113.13.218"'
EOF

echo "hosts.ini created:"
cat ansible/hosts.ini

echo "--------------------------------------"
echo "3) Running Ansible"
echo "--------------------------------------"

cd ansible
ansible-playbook -i hosts.ini site.yml
