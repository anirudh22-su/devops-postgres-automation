pipeline {
    agent any

    environment {
        SSH_KEY = credentials('jenkins-ssh-key')
    }

    stages {
        stage('Checkout Repo') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/anirudh22-su/devops-postgres-automation.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                cd terraform
                terraform init
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                cd terraform
                terraform apply -auto-approve
                '''
            }
        }

        stage('Run Ansible Automation') {
            steps {
                sh '''
                chmod +x run-oneclick-ansible.sh
                ./run-oneclick-ansible.sh
                '''
            }
        }
    }

    post {
        success {
            echo "🚀 Infrastructure deployed + PostgreSQL replication configured!"
        }
        failure {
            echo "❌ Build failed. Check logs."
        }
    }
}
