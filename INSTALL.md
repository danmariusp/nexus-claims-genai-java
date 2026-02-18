# How-To Guide: Deploying Nexus Claims GenAI API

This guide provides step-by-step instructions to deploy the GenAI-enabled Claim Status API to your own AWS environment.

## Prerequisites

Ensure you have the following tools installed and configured:

1.  **AWS CLI** (v2+): [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    - Run `aws configure` to set your credentials and default region (e.g., `us-east-1`).
2.  **Terraform** (v1.0+): [Install Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3.  **Docker**: [Install Guide](https://docs.docker.com/get-docker/)
    - Ensure the Docker daemon is running.
4.  **Helm**: [Install Guide](https://helm.sh/docs/intro/install/)
5.  **kubectl**: [Install Guide](https://kubernetes.io/docs/tasks/tools/)

## Quick Start (Automated Deployment)

We provide a script to automate the entire deployment process.

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/danmariusp/nexus-claims-genai-java.git
    cd nexus-claims-genai-java
    ```

2.  **Run the Deployment Script**:
    ```bash
    ./scripts/deploy_all.sh
    ```
    This script will:
    - validating AWS credentials.
    - Provision all infrastructure (IAM, VPC, EKS, DynamoDB, S3, API Gateway) via Terraform.
    - Build the Java application using Docker.
    - Push the Docker image to Amazon ECR.
    - Deploy the application to EKS using Helm.
    - Populate sample data into DynamoDB and S3.

3.  **Verify Deployment**:
    The script will output the **API Endpoint** at the end. You can test it immediately:

    ```bash
    # Get Claim Status
    curl <API_ENDPOINT>/claims/claim-101

    # Generate AI Summary
    curl -X POST <API_ENDPOINT>/claims/claim-101/summarize
    ```

## Manual Deployment Steps

If you prefer to deploy step-by-step or need to debug:

### 1. Infrastructure
```bash
# Bootstrap IAM Roles
cd iac/bootstrap
terraform init
terraform apply -auto-approve
ROLE_ARN=$(terraform output -raw builder_role_arn)

# Deploy Main Resources
cd ../main
terraform init
terraform apply -auto-approve -var="builder_role_arn=$ROLE_ARN"
```

### 2. Configure Access
```bash
aws eks update-kubeconfig --region us-east-1 --name nexus-claims-genai-java-cluster
```

### 3. Build and Push
```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

docker build -t $ECR_URL:latest ../../src/claims-service
docker push $ECR_URL:latest
```

### 4. Deploy Application
```bash
helm upgrade --install claims-service ../../src/helm/claims-service \
    --set image.repository=$ECR_URL \
    --set image.tag="latest"
```

## Troubleshooting

### Deployment Fails
- **Error: "Error acquiring the state lock"**: Terraform state is locked. If you are sure no other process is running, use `terraform force-unlock <LOCK_ID>`.
- **Error: "NoCredentialProviders"**: Run `aws configure` to ensure your CLI has valid keys.

### Application Issues
- **503 Service Unavailable**:
    - The application might still be starting. Wait a minute and try again.
    - Check pod status: `kubectl get pods`
    - Check logs: `kubectl logs -l app.kubernetes.io/name=claims-service`
- **GenAI Summary Fails**:
    - Ensure you have requested model access for **Claude** in the Amazon Bedrock console in `us-east-1`.
    - Check if the pod has correct IAM permissions (IRSA).

## Cleanup

To destroy all resources and avoid costs:

```bash
./scripts/destroy_all.sh
```
