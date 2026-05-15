resource "aws_backup_vault" "backend_code_vault" {
    name = var.backup_vault_name
    tags = {
        name = "s3-bucket-vault"
    }
}