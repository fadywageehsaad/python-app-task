# Python Application Infrastructure

This repository contains the Terraform configuration for setting up the infrastructure for a Python application, including a Virtual Network, Application Gateway, Container Registry, and App Service. Additionally, it includes a CI/CD pipeline using GitHub Actions to build and deploy the application.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- Azure subscription
- GitHub repository

## Runbook

## Terraform Configuration

### Provider Configuration

The `provider` block configures the Azure provider with the necessary subscription ID.

```hcl
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "00000000-0000-00000-00000-000000000000ss"
}
```

**Note** You need the following steps to log-in:
    - Add your subscription ID in the `main.tf` 
    - login to your terminal (use SP or anyother way to login to the terminal)

## Terraform

### Running Terraform

- Initialize Terraform:

```bash
terraform init
```

- Apply the Terraform Configuration:

```bash
terraform apply
```

- Confirm the apply action by typing `yes` when prompted.

This will set up the necessary infrastructure for your Python application and configure the CI/CD pipeline to automate the build and deployment process.


## Pipeline

### Setting Up GitHub Secrets
Go to your GitHub repository settings, and under the "Secrets" section, add the following secrets:

- ACR_LOGIN_SERVER: The login server name of your Azure Container Registry (e.g., myregistry.azurecr.io).
- `ACR_USERNAME`: The username for your Azure Container Registry.
- `ACR_PASSWORD`: The password for your Azure Container Registry.
- `AZURE_CREDENTIALS`: The JSON output from the Azure CLI command to create a service principal.
- `AZURE_APP_NAME`: The name of your Azure App Service.

### Deploying the Application

- Push Changes to GitHub: Push your changes to the main branch of your GitHub repository. This will trigger the CI/CD pipeline.

- Monitor the Pipeline: Go to the "Actions" tab in your GitHub repository to monitor the progress of the CI/CD pipeline. Ensure that all steps complete successfully.

- Verify Deployment: Once the pipeline completes, verify that the application is running by accessing the Azure App Service URL.

### Managing the Application

- Scaling the App Service: If you need to scale the App Service, you can do so from the Azure Portal. Navigate to your App Service and adjust the scale settings as needed.

- Monitoring and Logging: Use Azure Application Insights to monitor the performance and logs of your application. Ensure that the application_insights_key is correctly configured in your Terraform configuration.

- Updating the Application: To update the application, make changes to your code and push them to the main branch. The CI/CD pipeline will automatically build and deploy the new version.

- Rolling Back: If you need to roll back to a previous version, you can do so by redeploying an earlier Docker image from the Azure Container Registry.

By following this runbook, you can effectively deploy, manage, and update your Python application using the infrastructure and CI/CD pipeline configured in this repository.


