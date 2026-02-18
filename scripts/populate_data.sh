#!/bin/bash
set -e

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
TABLE_NAME="Claims"
BUCKET_NAME="referral-claim-notes-${ACCOUNT_ID}"

echo "Populating DynamoDB table '${TABLE_NAME}'..."
# claim-101
aws dynamodb put-item \
    --table-name "$TABLE_NAME" \
    --item '{"claimId": {"S": "claim-101"}, "status": {"S": "IN_PROGRESS"}, "customerId": {"S": "cust-555"}, "incidentDate": {"S": "2024-03-15"}, "description": {"S": "Car accident on highway"}}' \
    --region "$REGION"

# claim-102
aws dynamodb put-item \
    --table-name "$TABLE_NAME" \
    --item '{"claimId": {"S": "claim-102"}, "status": {"S": "APPROVED"}, "customerId": {"S": "cust-777"}, "incidentDate": {"S": "2024-02-20"}, "description": {"S": "Water damage in kitchen"}}' \
    --region "$REGION"

echo "Populating S3 bucket '${BUCKET_NAME}'..."
# claim-101.txt
echo "Customer called to report the accident. Police report filed. Car towed to the shop. Estimator reviewed damages. Waiting for parts." > claim-101.txt
aws s3 cp claim-101.txt "s3://${BUCKET_NAME}/claim-101.txt" --region "$REGION"

# claim-102.txt
echo "Plumber visited site. Leak identified behind the wall. Drywall removed. mitigation team arrived. Drying process started. Claim approved for repairs." > claim-102.txt
aws s3 cp claim-102.txt "s3://${BUCKET_NAME}/claim-102.txt" --region "$REGION"

# Cleanup
rm claim-101.txt claim-102.txt

echo "Data population complete."
