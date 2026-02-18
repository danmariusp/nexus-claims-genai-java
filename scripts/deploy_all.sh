#!/bin/bash
set -e

echo "================================================================"
echo "   Nexus Claims GenAI - Full Deployment Script"
echo "================================================================"

# 0. Check AWS Prerequisites
echo "[0/5] Checking AWS identity..."
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "Error: AWS credentials not configured. Please run 'aws configure' or set environment variables."
    exit 1
fi
CURRENT_IDENTITY=$(aws sts get-caller-identity --query Arn --output text)
echo "Deploying as: $CURRENT_IDENTITY"

# 1. Bootstrap Infrastructure (IAM Roles)
echo ""
echo "[1/5] Deploying Bootstrap Infrastructure (IAM)..."
cd "$(dirname "$0")/../iac/bootstrap"
terraform init
terraform apply -auto-approve

ROLE_ARN=$(terraform output -raw builder_role_arn)
echo "Builder Role ARN: $ROLE_ARN"

# 2. Main Infrastructure (EKS, VPC, DB, S3, API Gateway)
echo ""
echo "[2/5] Deploying Main Infrastructure (EKS, VPC, DB, S3, APIGW)..."
cd ../main
terraform init
terraform apply -auto-approve -var="builder_role_arn=$ROLE_ARN"

# Capture Outputs
CLUSTER_NAME=$(terraform output -raw cluster_name)
ECR_URL=$(terraform output -raw ecr_repository_url)
API_ENDPOINT=$(terraform output -raw api_endpoint)
REGION=$(aws configure get region)
if [ -z "$REGION" ]; then REGION="us-east-1"; fi

echo "Cluster: $CLUSTER_NAME"
echo "ECR: $ECR_URL"
echo "API: $API_ENDPOINT"

# 3. Configure Kubernetes Access
echo ""
echo "[3/5] Configuring kubectl..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

# 4. Build and Deploy Application
echo ""
echo "[4/5] Building and Deploying Application..."
cd ../.. # Back to project root

# Build Docker Image
echo "Logging into ECR..."
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ECR_URL"

echo "Building Docker image..."
docker build -t "$ECR_URL:latest" src/claims-service

echo "Pushing Docker image..."
docker push "$ECR_URL:latest"

# Deploy Helm Chart
echo "Deploying Helm Chart..."
helm upgrade --install claims-service ./src/helm/claims-service \
    --set image.repository="$ECR_URL" \
    --set image.tag="latest" \
    --wait

# 5. Populate Data
echo ""
echo "[5/5] Populating Mock Data..."
./scripts/populate_data.sh

echo ""
echo "================================================================"
echo "   Deployment Complete!"
echo "================================================================"
echo "API Endpoint: $API_ENDPOINT"
echo "Test Status: curl $API_ENDPOINT/claims/claim-101"
echo "Test GenAI:  curl -X POST $API_ENDPOINT/claims/claim-101/summarize"
echo "================================================================"
