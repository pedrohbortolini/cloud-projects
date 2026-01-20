# SNS Topic for Backup Notifications
# This topic will be used to send notifications about file backups to subscribers.
# The topic name and display name are generated using local variables and input variables.
resource "aws_sns_topic" "backup_notifications" {
  name         = local.sns_topic_name
  display_name = var.sns_display_name

}


# SNS Topic Policy to allow S3 to publish messages to the SNS topic
resource "aws_sns_topic_policy" "backup_notifications" {
  arn = aws_sns_topic.backup_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ToPublish"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.backup_notifications.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          StringLike = {
            "aws:SourceArn" = "arn:aws:s3:::${local.bucket_name}"
          }
        }
      }
    ]
  })

}
#Email Subscriptions to the SNS Topic
# This resource creates email subscriptions for each email address provided in the input variable.
#Count is used to create multiple subscriptions based on the length of the email_addresses list.
resource "aws_sns_topic_subscription" "email_notifications" {
  count = length(var.email_addresses)

  topic_arn = aws_sns_topic.backup_notifications.arn
  protocol  = "email"
  endpoint  = var.email_addresses[count.index]

  # Prevent Terraform from trying to confirm subscriptions automatically
  confirmation_timeout_in_minutes = 1

}

# S3 Bucket for File Backups
# This bucket will store the backup files. The bucket name is generated using local variables and input
resource "aws_s3_bucket" "backup_bucket" {
  bucket = local.bucket_name

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    local.commom_tags,
    {
      Name = "Simple File Backup Bucket"
      type = "storage"
    }
  )
}
# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "backup_bucket_versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.backup_bucket.id
  versioning_configuration {
    status = "Enabled"
  }

}
# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "backup_bucket_encryption" {
  count = var.enable_s3_encryption ? 1 : 0

  bucket = aws_s3_bucket.backup_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.s3_encryption_algorithm
    }
    bucket_key_enabled = var.s3_encryption_algorithm == "aws:kms" ? true : false
  }
}
# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "backup_bucket_pab" {
  bucket = aws_s3_bucket.backup_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "backup_bucket_lifecycle" {
  count = var.s3_lifecycle_expiration_days > 0 ? 1 : 0

  bucket = aws_s3_bucket.backup_bucket.id

  rule {
    id     = "backup_file_expiration"
    status = "Enabled"

    expiration {
      days = var.s3_lifecycle_expiration_days
    }

    # Also clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    # Handle versioned objects if versioning is enabled
    dynamic "noncurrent_version_expiration" {
      for_each = var.enable_s3_versioning ? [1] : []
      content {
        noncurrent_days = var.s3_lifecycle_expiration_days
      }
    }
  }
}

# S3 Bucket Notification to SNS Topic
resource "aws_s3_bucket_notification" "backup_notifications" {
  bucket = aws_s3_bucket.backup_bucket.id

  # Wait for SNS topic policy to be applied
  depends_on = [aws_sns_topic_policy.backup_notifications]

  topic {
    topic_arn = aws_sns_topic.backup_notifications.arn
    events    = var.notification_event_types
    id        = "BackupNotification"
  }
}
