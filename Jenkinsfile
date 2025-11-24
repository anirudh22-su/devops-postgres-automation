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
                    echo "[INFO] Copying SSH key into workspace"

                    cp /home/anirudh/jenkins.pem jenkins.pem
                    chmod 600 jenkins.pem

                    echo "[INFO] Key copied to: $WORKSPACE/jenkins.pem"
                '''
            }
        }

        stage('Run Ansible Automation') {
            steps {
                sh '''
                    chmod +x run-oneclick-ansible.sh

                    # Pass WORKSPACE so script can use correct key path
                    WORKSPACE=$WORKSPACE ./run-oneclick-ansible.sh
                '''
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

