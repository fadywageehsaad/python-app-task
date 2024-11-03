#!/bin/bash

# Variables - Update these with your cluster's information
CLUSTER_NAME="my-eks-cluster"
REGION="us-east-1"
IAM_POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
IAM_ROLE_NAME="AmazonEKSLoadBalancerControllerRole"
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
NAMESPACE="kube-system"
IAM_USER_ARN="arn:aws:iam::816069152850:user/admin"  # Replace with the actual IAM user or role ARN

# Helper function for error handling
error_exit() {
  echo "$1" 1>&2
  exit 1
}

# Step 1: Check for IAM OIDC provider and create if necessary
echo "Checking for IAM OIDC provider..."
OIDC_PROVIDER=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${REGION} --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
if [[ -z "$OIDC_PROVIDER" ]]; then
  echo "Creating IAM OIDC provider..."
  eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} --region ${REGION} --approve || error_exit "Failed to create IAM OIDC provider."
  OIDC_PROVIDER=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${REGION} --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
else
  echo "IAM OIDC provider already exists."
fi

# Step 2: Create IAM policy if it doesn't exist
echo "Checking for IAM policy..."
POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='${IAM_POLICY_NAME}'].Arn" --output text)
if [[ -z "$POLICY_ARN" ]]; then
  echo "Creating IAM policy..."
  curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json || error_exit "Failed to download IAM policy JSON."
  POLICY_ARN=$(aws iam create-policy --policy-name ${IAM_POLICY_NAME} --policy-document file://iam_policy.json --query "Policy.Arn" --output text) || error_exit "Failed to create IAM policy."
else
  echo "IAM policy already exists."
fi

# Step 3: Create IAM role with a trust policy for the AWS Load Balancer Controller
echo "Creating IAM role for the AWS Load Balancer Controller..."
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}"
        }
      }
    }
  ]
}
EOF
)

aws iam create-role --role-name ${IAM_ROLE_NAME} --assume-role-policy-document "${TRUST_POLICY}" >/dev/null 2>&1 || echo "IAM role already exists."
aws iam attach-role-policy --role-name ${IAM_ROLE_NAME} --policy-arn ${POLICY_ARN} || error_exit "Failed to attach policy to IAM role."

# Step 4: Create Kubernetes Service Account with IAM role annotation if it doesn't exist
echo "Checking for existing Kubernetes Service Account..."
if kubectl get serviceaccount ${SERVICE_ACCOUNT_NAME} -n ${NAMESPACE} >/dev/null 2>&1; then
  echo "Service Account ${SERVICE_ACCOUNT_NAME} already exists in the ${NAMESPACE} namespace."
else
  echo "Creating Kubernetes Service Account for the AWS Load Balancer Controller..."
  kubectl create namespace ${NAMESPACE} >/dev/null 2>&1 || true
  kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${NAMESPACE}
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${ACCOUNT_ID}:role/${IAM_ROLE_NAME}
EOF
fi

# Step 5: Install AWS Load Balancer Controller using Helm
echo "Installing AWS Load Balancer Controller using Helm..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n ${NAMESPACE} \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=${SERVICE_ACCOUNT_NAME} \
  --set region=${REGION} || error_exit "AWS Load Balancer Controller installation failed."

# Verification
echo "AWS Load Balancer Controller installation completed. Verifying..."
if ! kubectl rollout status deployment aws-load-balancer-controller -n ${NAMESPACE}; then
  error_exit "AWS Load Balancer Controller deployment failed to become ready."
else
  echo "AWS Load Balancer Controller is successfully installed and running."
fi