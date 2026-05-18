# AWS S3 Backup System
A Terraform module that makes automated AWS backup jobs for an S3 bucket with real-time emails and/or SMS notifications on suceess or failure.


## Architecture
```
AWS Backup (scheduled job)
        │
        ▼
  Backup Vault  ──► Vault Notifications
                            │
                            ▼
                       SNS Topic (backup-notification)
                      /     |      \
                     /      |       \
               Email(s)   SMS(s)   Lambda (backup-notifier)
                                        │
                                        ▼
                               Formats message & re-publishes
                               to same SNS topic with human-friendly text
```

## Prerequisites
- Terraform >= 1.3
- AWS provider ~> 5.0
- AWS credentials with permissions to manage Backup, S3, SNS, Lambda, and IAM
- The `lambda/` directory must exist at the module root containing `index.js`

## Usage
```hcl
module "s3_backup_notifier" {
  source = "./path/to/module"
 
  code_bucket_name           = "my-app-code-bucket"
  backup_vault_name          = "my-backup-vault"
  notification_emails        = ["ops@example.com", "alerts@example.com"]
  notification_phone_numbers = ["+15550001234"]
  backup_schedule            = "cron(0 2 ? * MON-FRI *)"
  retention_days             = 30
}
```
## Variables
 
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `code_bucket_name` | Name of the S3 bucket to back up | `string` | `""` | yes |
| `backup_vault_name` | Name of the AWS Backup vault | `string` | `"backup_vault"` | no |
| `notification_emails` | List of email addresses to notify | `list(string)` | `[]` | no |
| `notification_phone_numbers` | List of phone numbers to notify (E.164 format, e.g. `+15550001234`) | `list(string)` | `[]` | no |
| `backup_schedule` | Cron expression for the backup schedule | `string` | `"cron(0 2 ? * MON-FRI *)"` (2 AM UTC, Mon–Fri) | no |
| `aws_region` | AWS region to deploy into | `string` | `"us-west-2"` | no |
| `enable_versioning` | S3 versioning state (`"Enabled"` or `"Suspended"`) | `string` | `"Enabled"` | no |
| `retention_days` | Days to retain backup recovery points (must be > 7) | `number` | `30` | no |

