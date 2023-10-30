pipeline {
    agent any
    tools {
        terraform 'tf1.6'
    }
    stages {
        stage('Clone Git repo') {
            steps {
                git(
                branch: 'master',
                url: 'git@github.com:Suntorio/DevOps_Group_3.git',
                credentialsId: 'access_to_git'
                )
            }
        }
        stage('Terraform Initialize and Plan Destroy') {
            steps {
                sh '''
                cd ./jenkins/terraform_ansible_generic_instace_setup_template
                terraform init
                terraform plan -destroy -out=destroyplan.tfplan
                '''
            }
        }
        stage('Plan verification and user input for Destroy') {
            steps {
                input message: 'proceed or abort?', ok: 'ok'
            }
        }
        stage('Terraform Apply Destroy') {
            steps {
                sh '''
                cd ./jenkins/terraform_ansible_generic_instace_setup_template
                terraform apply destroyplan.tfplan
                '''
            }
        }
    }
}
