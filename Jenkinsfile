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
                    sh """
                        cd terraform
                        terraform init
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-access-key']
                ]) {
                    sh """
                        cd terraform
                        terraform apply -auto-approve
                    """
                }
            }
        }

  stage('Prepare SSH Key for Ansible') {
    steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'ssh-key', keyFileVariable: 'SSH_KEY')]) {
            sh '''
                mkdir -p /var/lib/jenkins/.ssh
                cp $SSH_KEY /var/lib/jenkins/.ssh/jenkins.pem
                chmod 600 /var/lib/jenkins/.ssh/jenkins.pem
                chown -R jenkins:jenkins /var/lib/jenkins/.ssh
            '''
        }
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
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Build failed."
        }
    }
}
