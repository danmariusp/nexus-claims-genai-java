output "app_role_arn" {
  value = aws_iam_role.app_role.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.claims_service.repository_url
}

output "s3_bucket_name" {
  value = aws_s3_bucket.claim_notes.bucket
}
