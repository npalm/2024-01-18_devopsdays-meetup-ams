
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

resource "github_actions_environment_secret" "aws_access_key" {
  environment     = github_repository_environment.demo.environment
  repository      = local.repository_name
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.demo.id
}

resource "github_actions_environment_secret" "aws_secret" {
  environment     = github_repository_environment.demo.environment
  repository      = local.repository_name
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = aws_iam_access_key.demo.secret
}


resource "github_repository_environment" "demo" {
  environment = "demo"
  repository  = local.repository_name
}
