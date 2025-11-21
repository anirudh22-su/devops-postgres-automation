#!/bin/bash
set -e

ANSIBLE_DIR="$HOME/oneclick-infra/ansible"

echo "-------------------------------------------"
echo "Creating Ansible project structure"
echo "-------------------------------------------"

# Roles
mkdir -p $ANSIBLE_DIR/roles/postgres/tasks
mkdir -p $ANSIBLE_DIR/roles/postgres_primary/tasks
mkdir -p $ANSIBLE_DIR/roles/postgres_primary/handlers
mkdir -p $ANSIBLE_DIR/roles/postgres_replica/tasks

###########################################
# site.yml (main playbook)
###########################################
cat << 'EOF' > $ANSIBLE_DIR/site.yml
---

- name: Install PostgreSQL 14 on DB nodes
  hosts: db
  become: yes
  roles:
    - postgres

- name: Configure Primary PostgreSQL
  hosts: primary
  become: yes
  roles:
    - postgres_primary

- name: Configure Replica PostgreSQL
  hosts: replica
  become: yes
  roles:
    - postgres_replica

EOF

###########################################
# Role: postgres (install pg14)
###########################################
cat << 'EOF' > $ANSIBLE_DIR/roles/postgres/tasks/main.yml
---

- name: Update apt cache
  apt:
    update_cache: yes

- name: Install PostgreSQL 14
  apt:
    name: postgresql
    state: present

- name: Ensure PostgreSQL is started
  service:
    name: postgresql
    state: started
    enabled: yes

EOF

###########################################
# Role: PRIMARY
###########################################
cat << 'EOF' > $ANSIBLE_DIR/roles/postgres_primary/tasks/main.yml
---

- name: Enable WAL settings
  lineinfile:
    path: /etc/postgresql/14/main/postgresql.conf
    regexp: "{{ item.regexp }}"
    line: "{{ item.line }}"
  loop:
    - { regexp: '^wal_level', line: 'wal_level = replica' }
    - { regexp: '^max_wal_senders', line: 'max_wal_senders = 10' }
    - { regexp: '^max_replication_slots', line: 'max_replication_slots = 5' }
    - { regexp: '^listen_addresses', line: "listen_addresses = '*'" }
  notify: restart postgres

- name: Allow replica access
  blockinfile:
    path: /etc/postgresql/14/main/pg_hba.conf
    block: |
      host replication replicator 10.50.4.0/24 md5

- name: Create replication user
  become_user: postgres
  shell: |
    psql -tc "SELECT 1 FROM pg_roles WHERE rolname='replicator'" | grep -q 1 ||
    psql -c "CREATE ROLE replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'StrongPass123';"

EOF

cat << 'EOF' > $ANSIBLE_DIR/roles/postgres_primary/handlers/main.yml
---

- name: restart postgres
  service:
    name: postgresql
    state: restarted

EOF

###########################################
# Role: REPLICA
###########################################
cat << 'EOF' > $ANSIBLE_DIR/roles/postgres_replica/tasks/main.yml
---

- name: Stop PostgreSQL
  service:
    name: postgresql
    state: stopped

- name: Remove old data
  file:
    path: /var/lib/postgresql/14/main
    state: absent

- name: Recreate data directory
  file:
    path: /var/lib/postgresql/14/main
    state: directory
    owner: postgres
    group: postgres
    mode: '0700'

- name: Base backup from primary
  become_user: postgres
  shell: |
    pg_basebackup -h {{ hostvars['primary']['ansible_host'] }} \
      -D /var/lib/postgresql/14/main \
      -U replicator -Fp -Xs -P -R
  environment:
    PGPASSWORD: "StrongPass123"

- name: Start PostgreSQL
  service:
    name: postgresql
    state: started

EOF

echo "-------------------------------------------"
echo "All Ansible files created successfully!"
echo "-------------------------------------------"
