#!/bin/bash
set -e

echo "--------------------------------------"
echo "1) Reading Terraform outputs"
echo "--------------------------------------"

BASTION_IP=$(terraform -chdir=terraform output -raw bastion_ip)
PRIMARY_IP=$(terraform -chdir=terraform output -raw primary_db_ip)
REPLICA_IP=$(terraform -chdir=terraform output -raw replica_db_ip)

echo "Bastion: $BASTION_IP"
echo "Primary: $PRIMARY_IP"
echo "Replica: $REPLICA_IP"

echo "--------------------------------------"
echo "2) Creating hosts.ini automatically"
echo "--------------------------------------"

ANSIBLE_DIR="$HOME/oneclick-infra/ansible"
mkdir -p $ANSIBLE_DIR

cat <<EOF > $ANSIBLE_DIR/hosts.ini
[db]
primary ansible_host=$PRIMARY_IP
replica ansible_host=$REPLICA_IP

[bastion]
bastion ansible_host=$BASTION_IP

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/jenkins.pem
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -i ~/.ssh/jenkins.pem ubuntu@$BASTION_IP"'
EOF

echo "hosts.ini created:"
cat $ANSIBLE_DIR/hosts.ini

echo "--------------------------------------"
echo "3) Running Ansible"
echo "--------------------------------------"

ansible-playbook -i $ANSIBLE_DIR/hosts.ini $ANSIBLE_DIR/site.yml

echo "--------------------------------------"
echo "DONE!"
echo "PostgreSQL primary + replica configured."
