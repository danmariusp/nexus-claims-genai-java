# Detailed Installation Guide

This document provides manual deployment steps and troubleshooting for the Nexus Claims GenAI API.

> **For the automated Quick Start, see [README.md](README.md).**

## Manual Deployment Steps

If you prefer to deploy step-by-step or need to debug:

### 1. Bootstrap Infrastructure
```bash
cd iac/bootstrap
terraform init
terraform apply -auto-approve
ROLE_ARN=$(terraform output -raw builder_role_arn)
```

### 2. Deploy Main Infrastructure
```bash
cd ../main
terraform init
terraform apply -auto-approve -var="builder_role_arn=$ROLE_ARN"
```

### 3. Configure Kubernetes Access
```bash
aws eks update-kubeconfig --region us-east-1 --name nexus-claims-genai-java-cluster
```

### 4. Build and Push Docker Image
```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

docker build -t $ECR_URL:latest ../../src/claims-service
docker push $ECR_URL:latest
```

### 5. Deploy Application
```bash
helm upgrade --install claims-service ../../src/helm/claims-service \
    --set image.repository=$ECR_URL \
    --set image.tag="latest"
```

### 6. Populate Data
```bash
cd ../..
./scripts/populate_data.sh
```

## Troubleshooting

### Terraform Issues
| Error | Solution |
|---|---|
| `Error acquiring the state lock` | Run `terraform force-unlock <LOCK_ID>` if no other process is running. |
| `NoCredentialProviders` | Run `aws configure` to set valid access keys. |

### Application Issues
| Symptom | Solution |
|---|---|
| **503 Service Unavailable** | The app may still be starting. Wait 1-2 minutes. Check: `kubectl get pods` and `kubectl logs -l app.kubernetes.io/name=claims-service` |
| **GenAI Summary Fails** | Ensure Anthropic Claude is accessible in Bedrock (`us-east-1`). First-time users may need to submit use case details. Check pod IAM permissions (IRSA). |
| **Docker Push Access Denied** | Ensure the CodeBuild role has `AmazonEC2ContainerRegistryPowerUser` policy. |
| **EKS Unauthorized** | Ensure the deploying user/role ARN is in EKS Access Entries (managed in `cicd.tf`). |
