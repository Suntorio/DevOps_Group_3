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
        // TF_WORK_DIR_ANSIBLE = 'jenkins/pacman_ec2_mine/ansible'
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
                    echo "yes" | terraform init -reconfigure
                    terraform plan -out=terraform.tfplan
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
        stage('Terraform Apply') {
            steps {
                dir(TF_WORK_DIR) {
                    sh 'terraform apply terraform.tfplan'
                }
            }
        }
        // stage('Get Terraform Outputs') {
        //     steps {
        //         dir(TF_WORK_DIR) {
        //             sh 'terraform output web-address-nodejs > ../ansible/instance_ip.txt'
        //         }
        //     }
        // }
        // stage('Run Ansible') {
        //     steps {
        //         withCredentials([sshUserPrivateKey(credentialsId: 'access_for_new_node_js_app', keyFileVariable: 'SSH_KEY')]) {
        //             dir(TF_WORK_DIR_ANSIBLE) {
        //             sh '''
        //             sleep 30
        //             ansible-playbook -i instance_ip.txt instance-docker-setup.yaml -u ubuntu --private-key=$SSH_KEY -e 'ansible_ssh_common_args="-o StrictHostKeyChecking=no"'
        //             '''
        //             }
        //         }
        //     }
        // }
    }
}