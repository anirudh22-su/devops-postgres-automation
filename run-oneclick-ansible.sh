#!/bin/bash
set -e

echo "--------------------------------------"
echo "1) Reading Terraform outputs"
echo "--------------------------------------"

BASTION=$(terraform -chdir=terraform output -raw bastion_ip)
PRIMARY=$(terraform -chdir=terraform output -raw primary_db_ip)
REPLICA=$(terraform -chdir=terraform output -raw replica_db_ip)

echo "Bastion: $BASTION"
echo "Primary: $PRIMARY"
echo "Replica: $REPLICA"

echo "--------------------------------------"
echo "2) Creating hosts.ini automatically"
echo "--------------------------------------"

cat > ansible/hosts.ini <<EOF
[bastion]
bastion ansible_host=$BASTION ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/jenkins.pem ansible_ssh_common_args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

[db]
primary ansible_host=$PRIMARY
replica ansible_host=$REPLICA

[db:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/jenkins.pem
ansible_ssh_common_args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand=\"ssh -W %h:%p -i /home/ubuntu/.ssh/jenkins.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$BASTION\""
EOF

echo "hosts.ini created:"
cat ansible/hosts.ini

echo "--------------------------------------"
echo "3) Running Ansible"
echo "--------------------------------------"

cd ansible
ansible-playbook -i hosts.ini site.yml
