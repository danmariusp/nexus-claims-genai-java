# nexus-claims-genai-java

## Overview
This repository contains the implementation of a GenAI-enabled Claim Status API on AWS.
The system is designed to provide claim status updates and AI-generated summaries of claim notes using Amazon Bedrock.

## Architecture
- **Compute**: Amazon EKS (EC2 Worker Nodes)
- **API Entry**: Amazon API Gateway (REST/HTTP)
- **Database**: Amazon DynamoDB (Claim Status)
- **Storage**: Amazon S3 (Claim Notes)
- **AI/ML**: Amazon Bedrock (Claude 3 Sonnet) for summarization
- **Infrastructure**: Terraform (IaC)
- **Deployment**: Helm Charts

## Directory Structure
- `src/`: Application source code (Java Spring Boot)
- `mocks/`: Sample data for Claims and Notes
- `apigw/`: API Gateway definitions/exports
- `iac/`: Terraform infrastructure code
    - `bootstrap/`: IAM roles for deployment
    - `main/`: Main infrastructure (EKS, DB, etc.)
- `pipelines/`: CI/CD definitions (CodeBuild)
- `scans/`: Security scan reports
- `observability/`: Logs and metrics screenshots

## Prerequisites
- AWS Account with Bedrock model access enabled (Claude 3 Sonnet)
- Terraform installed
- Docker installed
- Java 17+ installed
- `kubectl` and `aws-cli` configured

## Deployment Steps
1.  **Bootstrap Infrastructure**:
    ```bash
    cd iac/bootstrap
    terraform init && terraform apply
    ```
2.  **Deploy Main Infrastructure**:
    ```bash
    cd iac/main
    terraform init && terraform apply
    ```
4.  **Build and Push Docker Image**:
    ```bash
    cd src/claims-service
    mvn clean package -DskipTests
    docker build -t 374288915535.dkr.ecr.us-east-1.amazonaws.com/nexus-claims-genai-java/claims-service:latest .
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 374288915535.dkr.ecr.us-east-1.amazonaws.com
    docker push 374288915535.dkr.ecr.us-east-1.amazonaws.com/nexus-claims-genai-java/claims-service:latest
    ```
5.  **Deploy to EKS**:
    ```bash
    cd ../..
    # Obtain EKS credentials
    aws eks update-kubeconfig --region us-east-1 --name nexus-claims-genai-java-cluster --role-arn arn:aws:iam::374288915535:role/Introspect2BBuilderRole
    
    # Deploy Helm Chart
    helm upgrade --install claims-service ./src/helm/claims-service
    ```
6.  **Verify Deployment**:
    ```bash
    # Populate mock data
    ./scripts/populate_data.sh
    
    # Get LoadBalancer URL
    export SERVICE_URL=$(kubectl get svc claims-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    
    # Test API
    curl "http://$SERVICE_URL/claims/claim-101"
    curl -X POST "http://$SERVICE_URL/claims/claim-101/summarize"
    ```

## API Usage
- `GET /claims/{id}`: Get claim status
- `POST /claims/{id}/summarize`: Get claim summary
