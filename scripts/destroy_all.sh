#!/bin/bash
set -e

echo "================================================================"
echo "   Nexus Claims GenAI - Infrastructure Teardown"
echo "================================================================"

echo "WARNING: This will destroy all resources created by Terraform."
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

ROLE_ARN=$(cd iac/bootstrap && terraform output -raw builder_role_arn)

# 1. Destroy Main Infrastructure
echo ""
echo "[1/3] Destroying Main Infrastructure..."
cd "$(dirname "$0")/../iac/main"
terraform destroy -auto-approve -var="builder_role_arn=$ROLE_ARN"

# 2. Destroy Bootstrap Infrastructure
echo ""
echo "[2/3] Destroying Bootstrap Infrastructure..."
cd ../bootstrap
terraform destroy -auto-approve

# 3. Clean up local files
echo ""
echo "[3/3] Cleaning up local configuration..."
rm -rf ../../src/helm/claims-service/charts
rm -f ../../src/helm/claims-service/Chart.lock

echo "================================================================"
echo "   Teardown Complete!"
echo "================================================================"
