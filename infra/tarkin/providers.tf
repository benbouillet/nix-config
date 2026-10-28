provider "aws" {
  profile             = "homelab-deployment"
  allowed_account_ids = [var.aws_account_id]
  region              = "eu-west-3"
  default_tags {
    tags = {
      Name      = "tarkin"
      Project   = "nebula-lighthouse"
      ManagedBy = "terraform"
    }
  }
}

variable "aws_account_id" {
  type      = string
  sensitive = true
}
