pipeline {
    agent any
    tools {
     terraform 'tf1.6'
    }

    stages {
        stage('Clone Git repo') {
            steps {
                git(branch: 'master', url: 'https://github.com/Suntorio/DevOps_Group_3.git', credentialsId: 'access_to_git')
            }
        }
        stage('Plan') {
            steps {
                sh '''
                cd ./terraform_ansible_generic_instace_setup_bastion
                terraform init
                terraform plan -out=terraform.tfplan
                '''
            }
        }
        stage('Plan verification and user input') {
            steps {
                input message: 'proceed or abort?', ok: 'ok'
            }
        }
        stage('Apply') {
            steps {
                sh '''
                cd ./terraform_ansible_generic_instace_setup_bastion
                terraform apply terraform.tfplan
                '''
            }
        }
    }
}