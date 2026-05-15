resource "aws_s3_bucket" "backend_code" {
    bucket = var.code_bucket_name
}

resource "aws_s3_bucket_versioning" "backend_code_versioning" {
  bucket = aws_s3_bucket.backend_code.id
  versioning_configuration {
    status = var.enable_versioning
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backend_code_life_config" {
    bucket = aws_s3_bucket.backend_code.id

    rule {
        id = "expire-logs"
        status = "Enabled"

        filter {}

        noncurrent_version_expiration {
            noncurrent_days = var.retention_days
        }
    }   
}

resource "aws_backup_plan" "s3_backup_plan" {
    name = "s3-backup-plan"
    rule {
      rule_name = "daily-backup"
      target_vault_name = aws_backup_vault.backend_code_vault.name
      schedule = var.backup_schedule

      lifecycle {
        delete_after = var.retention_days
      }
    }
}

resource "aws_backup_selection" "s3_selection" {
  name = "s3-backup-collection"
  plan_id = aws_backup_plan.s3_backup_plan.id
  iam_role_arn = aws_iam_role.backup_access.arn

  resources = [
    aws_s3_bucket.backend_code.arn
  ]

}