pipeline {
    agent any

    environment {
        TF_VERSION = '0.15.0'  // Replace with your Terraform version
        TF_WORKING_DIR = 'jenkins/terraform_ansible_generic_instace_setup_template_HW_L38'  // Replace with the path to your Terraform scripts
    }

    stages {
        stage('Initialize') {
            steps {
                script {
                    // Install the required version of Terraform
                    sh "terraform --version"
                    sh "terraform init -input=false -lock=false ${TF_WORKING_DIR}"
                }
            }
        }

        stage('Destroy') {
            steps {
                script {
                    // Prompt for confirmation before destroying resources
                    input message: 'Do you really want to destroy the infrastructure?', ok: 'Yes, destroy it.'

                    // Execute Terraform destroy
                    sh "terraform destroy -auto-approve ${TF_WORKING_DIR}"
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