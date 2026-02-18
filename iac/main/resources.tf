data "aws_caller_identity" "current" {}

resource "aws_dynamodb_table" "claims" {
  name           = "Claims"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "claimId"

  attribute {
    name = "claimId"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-claims-table"
  }
}

resource "aws_s3_bucket" "claim_notes" {
  bucket = "referral-claim-notes-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-notes-bucket"
  }
}

resource "aws_ecr_repository" "claims_service" {
  name                 = "nexus-claims-genai-java/claims-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
