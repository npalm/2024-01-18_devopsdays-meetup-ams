resource "github_actions_secret" "aws_account_id" {
  repository      = local.repository_name
  secret_name     = "AWS_ACCOUNT_ID"
  plaintext_value = data.aws_caller_identity.current.account_id
}

resource "github_actions_variable" "aws_bucket_name" {
  repository    = local.repository_name
  variable_name = "AWS_BUCKET_NAME"
  value         = local.bucket_name
}

resource "github_repository_environment" "demo" {
  environment = "demo"
  repository  = local.repository_name
}
