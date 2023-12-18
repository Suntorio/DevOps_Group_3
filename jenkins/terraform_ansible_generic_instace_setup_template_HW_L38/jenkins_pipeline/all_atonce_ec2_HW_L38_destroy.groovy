pipeline {
    agent any

    // triggers {
    //     // Polls SCM periodically but the schedule is ignored if a webhook is set up
    //     githubPush()
    //     pollSCM('H * * * *')
    // }
    // parameters {
    //     string(name: 'ACTION', defaultValue: 'proceed', description: 'Action to take')
    // }
    tools {
        terraform 'tf1.6'
    }

        environment {
        // Define a variable to hold the output from the previous stage
        PREVIOUS_STAGE_OUTPUT = ''
        
        //My test variables
        TF_WORK_DIR = 'jenkins/terraform_ansible_generic_instace_setup_template_HW_L38'
        }

      stages {
        stage('Sparse Checkout') {
            steps {
                script {
                    checkout([$class: 'GitSCM', 
                              branches: [[name: 'master']],
                              doGenerateSubmoduleConfigurations: false,
                              extensions: [[
                                  $class: 'SparseCheckoutPaths', 
                                  sparseCheckoutPaths: [[path: TF_WORK_DIR]]
                              ]],
                              userRemoteConfigs: [[
                                  url: 'https://github.com/Suntorio/DevOps_Group_3.git'
                              ]]
                    ])
                }
            }
        }
          stage('Terraform Plan') {
            steps {
                dir(TF_WORK_DIR) {
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
                    input message: 'Do you really want to destroy the infrastructure?', ok: 'Yes, destroy it.'
                }
            }
        }
        stage('Terraform Apply Destroy') {
            steps {
                dir(TF_WORK_DIR){
                sh '''
                terraform apply destroyplan.tfplan
                '''
                }
            }
        }
    }
}