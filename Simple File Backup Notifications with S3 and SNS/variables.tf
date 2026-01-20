variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "simple-file-backup-bucket"
}

variable "sns_topic_name" {
  description = "Name for the SNS topic"
  type        = string
  default     = "simple-file-backup-notifications"
}

variable "sns_display_name" {
  description = "Display name for the SNS topic"
  type        = string
  default     = "Simple File Backup Notifications"

}

variable "email_addresses" {
  description = "List of email addresses to subscribe to the SNS topic for backup notifications"
  type        = list(string)
  default     = []

}

variable "enable_versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_s3_encryption" {
  description = "Enable server-side encryption on the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_encryption_algorithm" {
  description = "S3 encryption algorithm"
  type        = string
  default     = "AES256"
}

variable "s3_lifecycle_expiration_days" {
  description = "Number of days after which S3 objects are automatically deleted"
  type        = number
  default     = 0
}

variable "enable_s3_versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "notification_event_types" {
  description = "List of S3 event types to trigger notifications"
  type        = list(string)
  default     = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
}