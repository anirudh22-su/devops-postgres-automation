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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-access-key'
                ]]) {
                    sh '''
                        cd terraform
                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-access-key'
                ]]) {
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
                    echo "[INFO] Preparing SSH key for Ansible..."

                    # Jenkins key location (CORRECT)
                    SSH_KEY_PATH=/var/lib/jenkins/.ssh/jenkins.pem

                    # Ensure correct perms
                    sudo chmod 600 $SSH_KEY_PATH
                    sudo chown jenkins:jenkins $SSH_KEY_PATH

                    # Copy to workspace for Ansible
                    cp $SSH_KEY_PATH jenkins.pem

                    chmod 600 jenkins.pem
                '''
            }
        }

        stage('Run Ansible Automation') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-access-key'
                ]]) {
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


