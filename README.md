# Python App Task

This repository contains a simple Python application. The instructions below will help you set up the project, build and run it locally or in a Docker container, and deploy it to a Kubernetes cluster using AWS EKS.

## Table of Contents

- [Runbook](#runbook)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Run Terraform](#2-run-terraform)
  - [3. Run EKS helper script](#3-run-eks-helper-script)
  - [4. Update Github secrets to Deploy to Kubernetes on AWS EKS using ithub pipeline](#4-update-github-secrets)
- [Troubleshooting](#troubleshooting)

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/fadywageehsaad/python-app-task.git
cd python-app-task
```

### 2. Run Terraform

#### Prerequisites

- AWS account 
    - You need to have AWS account as this app required AWS EKS and other AWS resources
- IAM user or IAM role to be assumed
    - You need to have IAM user to be used for running the `terraform` code 
    - Export the credentials for your IAM user

    ```bash
    export AWS_ACCESS_KEY_ID=xxxxxxxxxx
    export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    ```

#### Run

1. **Make sure to update the values in the `main.tf` file under `terraform` folder**
    - it includes values like, VPC CIDR range and how many subnets and cluster name (feel free to keep it as is for quick test)

2. **Change your directory to the `terraform` directory**
```
cd terraform
```

3. **Initialize your terraform code**
```
terraform init
```

4. **Plan your code**
```
terraform plan
```

5. **If the plan looks good, then apply your the plan**
```
terraform apply
```


### 3. Run EKS helper script
This script is installing `aws-load-balancer-controller` into your cluster and adds all the necessary prerequistes

#### Prerequisites

#### AWS CLI Installation

The AWS Command Line Interface (CLI) allows you to interact with AWS services from your terminal or command prompt.

### Linux and macOS

1. **Download the AWS CLI Installer**:

   - For Linux:

     ```bash
     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
     ```

   - For macOS:

     ```bash
     curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
     ```

2. **Install AWS CLI**:

   - **Linux**:

     ```bash
     unzip awscliv2.zip
     sudo ./aws/install
     ```

   - **macOS**:

     ```bash
     sudo installer -pkg AWSCLIV2.pkg -target /
     ```

3. **Verify the Installation**:

   ```bash
   aws --version

### Windows

1. **Download the AWS CLI Installer from AWS CLI for Windows**:

2. **Run the Installer by opening AWSCLIV2.msi and following the installation prompts.**:

3. **Verify the Installation**:

   ```powershell
   aws --version


#### Helm Installation
Helm is a package manager for Kubernetes, which helps you define, install, and upgrade complex Kubernetes applications.

### Linux and macOS

1. **Install Helm**:

Download and install Helm using the script below, which automatically detects your OS:

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**Alternatively, for macOS users with Homebrew**:

```bash
brew install helm
```

2. **Verify the Installation**:

```bash
helm version
```

### Windows
Download the Helm Installer from Helm Releases.

1. **Extract and Move the helm.exe file**:

- Extract helm.exe from the downloaded .zip file.

- Move `helm.exe` to a directory in your system PATH (e.g., C:\Program Files\Helm), or add the directory to your PATH environment variable.
Verify the Installation:

2. **Open PowerShell and run**:

```powershell
helm version
```

**Alternatively, if you have Chocolatey installed, you can install Helm with**:

```powershell
choco install kubernetes-helm
```

#### kubectl Installation
kubectl is a command-line tool for interacting with Kubernetes clusters. It is essential for managing deployments and resources in Kubernetes.

### Linux
1. **Download the kubectl Binary**:

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

2. **Make the File Executable**:

```bash
chmod +x ./kubectl
```

3. **Move the Binary to Your PATH:

```bash
sudo mv ./kubectl /usr/local/bin/kubectl
```

4. **Verify the Installation**:

```bash
kubectl version --client
```

### macOS

1. **Use Homebrew to install kubectl**:

```bash
brew install kubectl
```

Alternatively, you can follow the Linux steps above by downloading the macOS binary.

### Windows
1. **Download the kubectl Binary from kubectl Releases**.

2. **Extract kubectl.exe from the downloaded .zip file**.

3. **Move kubectl.exe to a directory in your system PATH (e.g., C:\Program Files\kubectl), or add this directory to your PATH environment variable**.

4. **Verify the Installation**:

Open PowerShell and run:

```powershell
kubectl version --client
```

Alternatively, with Chocolatey:

```powershell
choco install kubernetes-cli
```

#### eksctl Installation
eksctl is a CLI tool for managing Amazon EKS clusters, making it easy to create, update, and delete clusters.

### Linux and macOS

1. **Download eksctl**:

```bash
curl -LO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"
```

2. **Extract and Move the Binary**:

```bash
tar -xzf eksctl_$(uname -s)_amd64.tar.gz -C /usr/local/bin
```

3. **Verify the Installation**:

```bash
eksctl version
```

Alternatively, for macOS users with Homebrew:

```bash
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
```

### Windows
1. **Download eksctl from eksctl Releases**.

2. **Extract eksctl.exe from the downloaded .zip file**.

3. **Move eksctl.exe to a directory in your PATH (e.g., C:\Program Files\eksctl), or add the directory to your PATH environment variable**.

4. **Verify the Installation**:

Open PowerShell and run:

```powershell
eksctl version
```

Alternatively, if you have Chocolatey installed, you can install eksctl with:

```powershell
choco install eksctl
```

#### Run

1. Add your values
    - in the lines from `4` to `10` in the `scripts/aws_load_balancer_controller.sh` file there are some values need to change based on your own use
        - CLUSTER_NAME          -> add your AWS EKS cluster name
        - REGION                -> add your AWS region that holds the EKS cluster
        - IAM_POLICY_NAME       -> the name of the IAM policy that will be used by the `aws-load-balancer-controller`
        - IAM_ROLE_NAME         -> the name of the IAM role that will be used by the `aws-load-balancer-controller`
        - SERVICE_ACCOUNT_NAME  -> the name of the service account that will be used by the `aws-load-balancer-controller`
        - NAMESPACE             -> Namespace for `aws-load-balancer-controller` creation
        - IAM_USER_ARN          -> IAM user arn for the user that will deploy the 
        `aws-load-balancer-controller`

2. Run the script
```bash
sh +x scripts/aws_load_balancer_controller.sh
```

### Update Github Secrets

**Add the follwoing github repo secret for the Github actions to run correctly**

- AWS_ACCOUNT_ID        -> your aws access key id
- AWS_SECRET_ACCESS_KEY -> your secret access key
- AWS_REGION            -> aws region
- EKS_CLUSTER_NAME      -> name of the EKS cluster



