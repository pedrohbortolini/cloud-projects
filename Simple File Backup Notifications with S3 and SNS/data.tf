
# Get information about the current AWS caller identity
data "aws_caller_identity" "current" {}

# Get information about the current AWS region declared on the provider or default region on the variable 
data "aws_region" "current" {}

# Generate a random string to append to resource names for uniqueness especially for S3 bucket names that must be globally unique
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  commom_tags = merge(
    { Project   = "Simple File Backup Notifications with S3 and SNS",
      Owner     = "phz",
      ManagedBy = "OpenTofu"
    }, var.tags


  )

  # Generate unique resource names
  bucket_name    = "${var.s3_bucket_prefix}-${random_string.suffix.result}"
  sns_topic_name = "${var.sns_topic_name}-${random_string.suffix.result}"
}

