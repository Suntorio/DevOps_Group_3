pipeline {
    agent any
    
    parameters {
        string(name: 'ACTION', defaultValue: 'proceed', description: 'Action to take')
    }
    tools {
        terraform 'tf1.6'
    }

    environment {
        // Define a variable to hold the output from the previous stage
        PREVIOUS_STAGE_OUTPUT = ''
    }

    stages {
        stage('Clone Git repo') {
            steps {
                git(
                    branch: 'master', 
                    url: 'https://github.com/Suntorio/DevOps_Group_3.git', 
                    credentialsId: 'access_to_git'
                )
            }
        }
        stage('Terraform Plan') {
            steps {
                dir('DevOps_jenkins_tf_ans_node_js_Setup/terraform_ansible_generic_instace_setup_template') {
                    sh '''
                    echo "yes" | terraform init
                    terraform plan -destroy -out=destroyplan.tfplan
                    '''
                    script {
                        env.PREVIOUS_STAGE_OUTPUT = sh(script: 'echo "Output from previous stage"', returnStdout: true).trim()
                    }
                }
            }
        }
        stage('Approval') {
            steps {
                // Echo the output from the previous stage
                echo "Output from the Previous Stage: ${env.PREVIOUS_STAGE_OUTPUT}"
                // Ask for the input to proceed or abort the build
                script {
                    def userInput = input(
                        id: 'userInput', 
                        message: 'Choose to proceed or abort the build:', 
                        parameters: [choice(name: 'Proceed?', choices: ['proceed', 'abort'], description: 'Proceed or Abort')]
                    )
                    if (userInput == 'abort') {
                        error('Aborting the build.')
                    }
                }
            }
        }
        stage('Terraform Apply Destroy') {
            steps {
                dir('DevOps_jenkins_tf_ans_node_js_Setup/terraform_ansible_generic_instace_setup_template'){
                sh '''
                terraform apply destroyplan.tfplan
                '''
                }
            }
        }
    }
}
