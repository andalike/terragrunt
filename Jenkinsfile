pipeline {
    agent any

    environment {
        // Define the path to the tools directory
        TOOLS_DIR = "${WORKSPACE}/tools"
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
                    // Download and install TFLint if not already installed
                    def tflintInstalled = fileExists("${TOOLS_DIR}/tflint")
                    if (!tflintInstalled) {
                        sh "mkdir -p ${TOOLS_DIR}"
                        sh "curl -L https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip -o ${TOOLS_DIR}/tflint_linux_amd64.zip"
                        sh "unzip ${TOOLS_DIR}/tflint_linux_amd64.zip -d ${TOOLS_DIR}"
                        sh "chmod +x ${TOOLS_DIR}/tflint"
                        sh "${TOOLS_DIR}/tflint --version"
                    }

                    // Download and install TfSec if not already installed
                    def tfsecInstalled = fileExists("${TOOLS_DIR}/tfsec")
                    if (!tfsecInstalled) {
                        sh "mkdir -p ${TOOLS_DIR}"
                        sh "curl -L https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64 -o ${TOOLS_DIR}/tfsec"
                        sh "chmod +x ${TOOLS_DIR}/tfsec"
                        sh "${TOOLS_DIR}/tfsec --version"
                    }

                    // Download and install Terraform if not already installed
                    def terraformInstalled = fileExists("${TOOLS_DIR}/terraform")
                    if (!terraformInstalled) {
                        sh "mkdir -p ${TOOLS_DIR}"
                        sh "curl -L https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip -o ${TOOLS_DIR}/terraform.zip"
                        sh "unzip ${TOOLS_DIR}/terraform.zip -d ${TOOLS_DIR}"
                        sh "chmod +x ${TOOLS_DIR}/terraform"
                        sh "${TOOLS_DIR}/terraform --version"
                    }


                    // Download and install Terragrunt if not already installed
                    def terragruntInstalled = fileExists("${TOOLS_DIR}/terragrunt")
                    if (!terragruntInstalled) {
                        sh "mkdir -p ${TOOLS_DIR}"
                        sh "curl -L https://github.com/gruntwork-io/terragrunt/releases/download/v0.47.0/terragrunt_linux_amd64 -o ${TOOLS_DIR}/terragrunt"
                        sh "chmod +x ${TOOLS_DIR}/terragrunt"
                        sh "${TOOLS_DIR}/terragrunt --version"
                    }

                }
            }
        }

        stage('Run TfLint') {
            steps {
                script {
                    // Run TFLint on your Terraform code
                    def tflintExitCode = sh(
                        script: "${TOOLS_DIR}/tflint --config ${WORKSPACE}/.tflint.hcl",
                        returnStatus: true
                    )

                    if (tflintExitCode != 0) {
                        error "TFLint scan failed with exit code: ${tflintExitCode}"
                    }
                }
            }
        }

        stage('Run TfSec Scan') {
            steps {
                script {
                    // Ensure that TfSec is installed before running it
                    if (!fileExists("${TOOLS_DIR}/tfsec")) {
                        error "TfSec is not installed. Please check the installation script."
                    }

                    // Run TfSec scan on your Terraform code
                    def tfsecExitCode = sh(
                        script: "${TOOLS_DIR}/tfsec -f junit,default --out tfsec --config-file tfsec.yaml --no-color --include-passed",
                        returnStatus: true
                    )

                    if (tfsecExitCode != 0) {
                        error "TfSec scan failed with exit code: ${tfsecExitCode}"
                    }
                }
            }
        }

        stage('Configure Credentials') {
            steps {
                script {
                    awsAccessKeyId = ""
                    awsSecretAccessKey = ""
                    sh "aws configure set aws_access_key_id ${awsAccessKeyId}"
                    sh "aws configure set aws_secret_access_key ${awsSecretAccessKey}"
                    sh 'aws s3 ls'
                }
            }
        }

         stage('Build Infra') {
            steps {
                script {
                    // Ensure that TfSec is installed before running it
                    dir(path: 'live/dev/ap-south-1/vpc') {
                    echo 'Present Directory'
                    sh 'pwd'
                    sh 'aws sts get-caller-identity'
                    sh "${TOOLS_DIR}/terragrunt --version"
                    sh "${TOOLS_DIR}/terraform --version"
                    sh "${TOOLS_DIR}/terragrunt init"
                    sh "${TOOLS_DIR}/terragrunt validate"
                    sh "${TOOLS_DIR}/terragrunt plan"
                    sh "${TOOLS_DIR}/terragrunt apply -auto-approve"
                }
                }
            }
        }
    }
}