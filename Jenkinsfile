pipeline {
    agent any

    environment {
        // Define the path to the tools directory
        TOOLS_DIR = "${WORKSPACE}/tools"
        TERRAFORM_IMAGE = 'hashicorp/terraform:1.5.0' // Use the desired Terraform version
    }

    stages {
        stage('Clean Workspace') {
            steps {
                // Clean up files and directories in the workspace
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                // Use the PAT as an environment variable for the Git checkout
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/feature-01']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    submoduleCfg: [],
                    userRemoteConfigs: [
                        [url: 'https://github.com/andalike/terragrunt', credentialsId: '']
                    ]
                ])
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    // Create a Docker container with Terraform
                    sh "docker run -v ${WORKSPACE}:${WORKSPACE} -w ${WORKSPACE} --rm ${TERRAFORM_IMAGE} terraform --version"
                }
            }
        }

        stage('Run TfLint') {
            steps {
                script {
                    // Run TFLint on your Terraform code using the Docker container
                    sh "docker run -v ${WORKSPACE}:${WORKSPACE} -w ${WORKSPACE} --rm ${TERRAFORM_IMAGE} tflint --config .tflint.hcl"
                }
            }
        }

        stage('Run TfSec Scan') {
            steps {
                script {
                    // Run TfSec scan on your Terraform code using the Docker container
                    sh "docker run -v ${WORKSPACE}:${WORKSPACE} -w ${WORKSPACE} --rm ${TERRAFORM_IMAGE} tfsec -f junit,default --out tfsec --config-file tfsec.yaml --no-color --include-passed"
                }
            }
        }

        stage('Build Infra') {
            steps {
                script {
                    // Change to the appropriate directory and run Terraform commands
                    dir(path: 'live/dev/ap-south-1/vpc') {
                        echo 'Present Directory'
                        sh 'pwd'
                        sh "docker run -v ${WORKSPACE}:${WORKSPACE} -w ${WORKSPACE} --rm ${TERRAFORM_IMAGE} terragrunt --version"
                        sh "docker run -v ${WORKSPACE}:${WORKSPACE} -w ${WORKSPACE} --rm ${TERRAFORM_IMAGE} terraform init"
                        sh "docker run -v ${WORKSPACE}:${WORKSPACE} -w ${WORKSPACE} --rm ${TERRAFORM_IMAGE} terraform validate"
                        sh "docker run -v ${WORKSPACE}:${WORKSPACE} -w ${WORKSPACE} --rm ${TERRAFORM_IMAGE} terraform plan"
                        sh "docker run -v ${WORKSPACE}:${WORKSPACE} -w ${WORKSPACE} --rm ${TERRAFORM_IMAGE} terraform apply -auto-approve"
                    }
                }
            }
        }
    }
}
