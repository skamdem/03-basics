# terraform setup

terraform {
  required_version = "1.5.0"

  # Remote backend specified as S3 bucket
  backend "s3" {
    bucket         = "devops-demos-terraform-state-bucket"
    key            = "03-basics/terraform.tfstate" # Matches repo name.
    region         = "us-east-1"
    dynamodb_table = "devops-demos-tfstate-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.2.0"
    }
  }
}