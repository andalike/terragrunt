# Jenkins Pipeline for Terraform Infrastructure

This Jenkins pipeline is designed to automate the process of code validation and infrastructure deployment using Terraform. It is triggered by GitHub Merge Requests and consists of two stages:

1. **Code Validation Stage**
   - TFSec Check: Validates the Terraform code using [TFSec](https://github.com/tfsec/tfsec).
   - TFLint Check: Performs linting of Terraform code using [TFLint](https://github.com/terraform-linters/tflint).
   - Update Status: Updates the status of the Merge Request on GitHub with the results of TFSec and TFLint checks.

2. **Infrastructure Deployment Stage**
   - terragrunt init: Initializes Terragrunt for the specified environment.
   - terragrunt validate: Validates the Terraform configuration using Terragrunt.
   - terragrunt plan: Generates a Terraform plan using Terragrunt.
   - Manual Approval (for 'main' branch only): Requires manual approval before proceeding further.
   - terragrunt apply (for 'main' branch only): Applies the Terraform changes if the branch is 'main'.

**Note:** The pipeline is designed to be triggered by GitHub Webhooks, specifically when a Merge Request is received. It ensures that changes to multiple environments (e.g., dev and test) are not deployed simultaneously, avoiding potential conflicts.

## Prerequisites
Before using this pipeline, ensure you have the following:

- Jenkins server set up and running.
- Jenkins plugins installed for GitHub integration and Terraform support.
- Terragrunt and Terraform installed on the Jenkins agent.
- TFSec and TFLint installed on the Jenkins agent.
- GitHub Webhooks configured to trigger Jenkins pipelines on Merge Request events.

## Usage
1. Create a PR in the terraform module repo()
2. If the PR is raised, the pipeline() will run and update the status to Github
3. If the MR is raised in the main branch, then the Pipeline() will trigger.
4. The pipeline will perform a terragrunt init, terragrunt validate, terragrunt plan.
5. A Manual approval will be required to perform a terragrunt approval
6. The only action required from user is a PR(Pull Request) on the specific branch(feature-01/feature-02 ), MR(Approving a Merge Request on Main Branch) and Manual Approval from the user.

## GitHub Configuration
Ensure the following GitHub settings are in place:

1. Webhook on GitHub repository to send Merge Request events to the Jenkins server.
2. Set up the webhook payload to include the necessary details required for Jenkins to identify the merge request and repository. This is done using the plugin of Jenkins with Github.

## Pipeline Behavior
- The pipeline will be triggered automatically when a Merge Request is opened or updated on GitHub.

- It will first perform code validation using TFSec and TFLint and update the GitHub status with the results.

- If the Merge Request is approved and the branch is the 'main' branch, it will wait for manual approval before proceeding to the Terraform deployment stage.

- In the 'main' branch, once manual approval is granted, the pipeline will initialize, validate, and plan the Terraform changes using Terragrunt.

- If all stages are successful, it will trigger a Terragrunt apply to deploy the infrastructure.

- The pipeline will ensure that only one environment's changes are deployed at a time to prevent conflicts.

- In case of changes to multiple environments, the pipeline will be aborted to avoid concurrent deployments.

## Security Considerations
- Protect sensitive information, such as API tokens and credentials, using Jenkins credential management.
- Restrict access to Jenkins and ensure it is properly secured.

## Pre-Requisite
- Create a table inDynamoDB(Primary Key : LockID)
- Create a S3 Bucket

Please refer to the Jenkins documentation for more information on setting up Jenkins pipelines and integrating with GitHub.

