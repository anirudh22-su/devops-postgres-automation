pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = "true"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/anirudh22-su/devops-postgres-automation.git',
                        credentialsId: 'github-token'
                    ]]
                ])
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-access-key']
                ]) {
                    sh '''
                        cd terraform
                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-access-key']
                ]) {
                    sh '''
                        cd terraform
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Prepare SSH Key for Ansible') {
            steps {
                sh '''
                    echo "[INFO] Copying SSH key for Ansible..."

                    # Ensure ubuntu user ssh directory exists
                    sudo mkdir -p /home/ubuntu/.ssh

                    # Copy your key from actual EC2 path
                    sudo cp /home/anirudh/jenkins.pem /home/ubuntu/.ssh/jenkins.pem

                    # Set correct permission
                    sudo chmod 600 /home/ubuntu/.ssh/jenkins.pem
                    sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/jenkins.pem

                    echo "[INFO] SSH key successfully placed at /home/ubuntu/.ssh/jenkins.pem"
                '''
            }
        }

        stage('Run Ansible Automation') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-access-key']
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                        chmod +x run-oneclick-ansible.sh
                        ./run-oneclick-ansible.sh
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Build failed."
        }
    }
}
