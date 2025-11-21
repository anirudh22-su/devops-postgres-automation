pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
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
                sh """
                cd terraform
                terraform init
                """
            }
        }

        stage('Terraform Apply') {
            steps {
                sh """
                cd terraform
                terraform apply -auto-approve
                """
            }
        }

        stage('Run Ansible Automation') {
            steps {
                sh """
                chmod +x run-oneclick-ansible.sh
                ./run-oneclick-ansible.sh
                """
            }
        }
    }

    post {
        failure {
            echo "❌ Build failed."
        }
        success {
            echo "✅ Build completed successfully."
        }
    }
}
