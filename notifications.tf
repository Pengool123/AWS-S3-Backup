data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "backup_notifier" {
  function_name    = "backup-notifier"
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.backup_notif.arn
    }
  }
}

resource "aws_sns_topic" "backup_notif" {
  name = "backup-notification"
}

resource "aws_sns_topic_subscription" "email" {
  count = length(var.notification_emails)
  topic_arn = aws_sns_topic.backup_notif.arn
  protocol = "email"
  endpoint = var.notification_emails[count.index]
}

resource "aws_sns_topic_subscription" "sms" {
  count = length(var.notification_phone_numbers)
  topic_arn = aws_sns_topic.backup_notif.arn
  protocol = "sms"
  endpoint = var.notification_phone_numbers[count.index]
}

resource "aws_backup_vault_notifications" "backup_events" {
  backup_vault_name = aws_backup_vault.backend_code_vault.name
  sns_topic_arn = aws_sns_topic.backup_notif.arn
  backup_vault_events = [
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED"
  ]
}

resource "aws_sns_topic_policy" "backup_sns_policy" {
  arn = aws_sns_topic.backup_notif.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Effect = "Allow"
        Principal = { Service = "backup.amazonaws.com" }
        Action = "sns:Publish"
        Resource = aws_sns_topic.backup_notif.arn
    }]
  })
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.backup_notif.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.backup_notifier.arn
}

resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.backup_notif.arn
}