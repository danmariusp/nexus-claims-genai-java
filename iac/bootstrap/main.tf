provider "aws" {
  region = "us-east-1"
}

data "aws_iam_policy" "administrator_access" {
  name = "AdministratorAccess"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "builder_role" {
  name = "Introspect2BBuilderRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            data.aws_caller_identity.current.arn
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "builder_role_admin_policy" {
  role       = aws_iam_role.builder_role.name
  policy_arn = data.aws_iam_policy.administrator_access.arn
}

output "builder_role_arn" {
  value = aws_iam_role.builder_role.arn
}
