variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "builder_role_arn" {
  description = "ARN of the role to assume for deployment"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  default     = "nexus-claims-genai-java"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}
