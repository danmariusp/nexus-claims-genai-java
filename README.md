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
3.  **Build and Push Docker Image**:
    ```bash
    # (Commands to be added)
    ```
4.  **Deploy to EKS**:
    ```bash
    # (Helm commands to be added)
    ```

## API Usage
- `GET /claims/{id}`: Get claim status
- `POST /claims/{id}/summarize`: Get claim summary
