output "sns_topic_arn" {
  description = "ARN of the SNS topic used for backup notifications"
  value       = aws_sns_topic.backup_notif.arn
}

output "backup_vault_name" {
  description = "Name of the AWS Backup vault"
  value       = aws_backup_vault.backend_code_vault.name
}

output "backup_vault_arn" {
  description = "ARN of the AWS Backup vault"
  value       = aws_backup_vault.backend_code_vault.arn
}

output "lambda_function_arn" {
  description = "ARN of the backup notifier Lambda function"
  value       = aws_lambda_function.backup_notifier.arn
}

output "lambda_function_name" {
  description = "Name of the backup notifier Lambda function"
  value       = aws_lambda_function.backup_notifier.function_name
}