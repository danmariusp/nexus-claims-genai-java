# nexus-claims-genai-java

## Overview
This repository contains the implementation of a GenAI-enabled Claim Status API on AWS.
The system provides claim status updates and AI-generated summaries of claim notes using Amazon Bedrock (Claude 3 Sonnet).

For the full solution rationale, architecture diagram, and proof of concept evidence, see [SOLUTION_ARCHITECTURE.md](SOLUTION_ARCHITECTURE.md).

## Architecture
- **AI/ML**: Amazon Bedrock (Claude 3 Sonnet) for summarization
- **Compute**: Amazon EKS (EC2 Worker Nodes)
- **API Entry**: Amazon API Gateway (HTTP API) + Network Load Balancer
- **Database**: Amazon DynamoDB (Claim Status)
- **Storage**: Amazon S3 (Claim Notes)
- **Infrastructure**: Terraform (IaC)
- **Deployment**: Helm Charts
- **CI/CD**: AWS CodeBuild

## API Usage
- `GET /claims/{id}` — Retrieve claim status from DynamoDB
- `POST /claims/{id}/summarize` — Generate AI summary of claim notes via Bedrock

## Directory Structure
```
├── src/                       # Application source code (Java Spring Boot) + Helm charts
├── iac/                       # Terraform infrastructure code
│   ├── bootstrap/             # IAM roles for deployment
│   └── main/                  # Main infrastructure (EKS, VPC, DB, S3, API Gateway)
├── pipelines/                 # CI/CD definitions (CodeBuild buildspec)
├── scripts/                   # Deployment and data population scripts
├── mocks/                     # Sample data for Claims and Notes
├── images/                    # AWS Console screenshots (proof of deployment)
└── SOLUTION_ARCHITECTURE.md   # Architecture rationale and validation evidence
```

## Prerequisites

Ensure you have the following tools installed and configured:

1.  **AWS CLI** (v2+): [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    - Run `aws configure` to set your credentials and default region (`us-east-1`).
2.  **Terraform** (v1.0+): [Install Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3.  **Docker**: [Install Guide](https://docs.docker.com/get-docker/) — ensure the daemon is running.
4.  **Helm**: [Install Guide](https://helm.sh/docs/intro/install/)
5.  **kubectl**: [Install Guide](https://kubernetes.io/docs/tasks/tools/)

## Quick Start (Automated Deployment)

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
    - Validate AWS credentials.
    - Provision all infrastructure (IAM, VPC, EKS, DynamoDB, S3, API Gateway) via Terraform.
    - Build the Java application using Docker.
    - Push the Docker image to Amazon ECR.
    - Deploy the application to EKS using Helm.
    - Populate sample data into DynamoDB and S3.

3.  **Verify Deployment**:
    The script outputs the **API Endpoint** at the end. Test it immediately:
    ```bash
    # Get Claim Status
    curl <API_ENDPOINT>/claims/claim-101

    # Generate AI Summary
    curl -X POST <API_ENDPOINT>/claims/claim-101/summarize
    ```

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

## Cleanup

To destroy all resources and avoid costs:

```bash
./scripts/destroy_all.sh
```
