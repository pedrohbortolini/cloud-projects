terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
  required_version = ">=1.5.0"
}


provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "Simple File Backup Notifications with S3 and SNS"
    }
  }

}

