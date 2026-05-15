variable "code_bucket_name" {
    description = "The name of the bucket"
    type = string
}

variable "backup_vault_name" {
    description = "The name of the backup vault"
    type = string
    default = "backup_vault"
}

variable "notification_emails" {
    description = "List of emails to notify when backup succeeds or fails"
    type = list(string)
    default = []
}

variable "notification_phone_numbers" {
    description = "List of phone numbers to notify when backup succeeds or fails"
    type = list(string)
    default = []

    //prevent API errors
    validation {
      condition = alltrue([for i in var.notification_phone_numbers : startswith(i, "+")])
      error_message = "Invalid phone number must be in E.164 format (+10120120123)"
    }
}

variable "backup_schedule" {
    description = "The hour in which the s3 bucket will make a new version"
    type = string
    //2 AM UTC workdays
    default = "cron(0 2 ? * MON-FRI *)"
}

variable "aws_region" {
    description = "AWS region"
    type = string
    default = "us-west-2"
}

variable "enable_versioning" {
    description = "Enables versioning"
    type = string
    default = "Enabled"

    validation {
      condition = contains(["Enabled", "Suspended"], var.enable_versioning)
      error_message = "Must be 'Enabled' or 'Suspended'."
    }
}

variable "retention_days" {
    description = "How many days recovery points last"
    type = number
    default = 30

    validation {
        condition     = var.retention_days > 7
        error_message = "retention_days must be greater than 7 to allow STANDARD_IA transition."
    }
}
