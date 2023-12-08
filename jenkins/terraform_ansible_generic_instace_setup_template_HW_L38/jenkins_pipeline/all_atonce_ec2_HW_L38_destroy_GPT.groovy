pipeline {
    agent any

    tools {
        terraform 'tf1.6'
    }

    environment {
        TF_VERSION = '1.6.3'  // Replace with your Terraform version
        TF_WORKING_DIR = 'jenkins/terraform_ansible_generic_instace_setup_template_HW_L38'  // Replace with the path to your Terraform scripts
    }

     stages {
        stage('Initialize') {
            steps {
                script {
                    // Install the required version of Terraform
                    sh "terraform --version"
                    dir(TF_WORKING_DIR) {
                        sh "terraform init -input=false -lock=false"
                    }
                }
            }
        }

        stage('Destroy') {
            steps {
                script {
                    // Prompt for confirmation before destroying resources
                    input message: 'Do you really want to destroy the infrastructure?', ok: 'Yes, destroy it.'

                    // Execute Terraform destroy
                    dir(TF_WORKING_DIR) {
                        sh "terraform destroy -auto-approve"
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace after completion
            cleanWs()
        }
    }
}