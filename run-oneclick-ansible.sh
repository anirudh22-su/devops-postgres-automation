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

# Jenkins workspace
ANSIBLE_DIR="$WORKSPACE/ansible"

echo "--------------------------------------"
echo "2) Creating hosts.ini automatically"
echo "--------------------------------------"

cat <<EOF > "$ANSIBLE_DIR/hosts.ini"
[db]
primary ansible_host=$PRIMARY
replica ansible_host=$REPLICA

[bastion]
bastion ansible_host=$BASTION

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/jenkins.pem
ansible_ssh_common_args=-o ProxyCommand="ssh -W %h:%p -i /var/lib/jenkins/.ssh/jenkins.pem ubuntu@$BASTION"
EOF

echo "--------------------------------------"
echo "3) Running Ansible"
echo "--------------------------------------"

cd "$ANSIBLE_DIR"
ansible-playbook site.yml

echo "PostgreSQL primary + replica configured."
