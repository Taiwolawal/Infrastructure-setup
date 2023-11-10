data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db-creds-v2"
}

data "aws_caller_identity" "current" {}