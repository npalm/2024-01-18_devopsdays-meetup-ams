
resource "aws_iam_user" "demo" {
  name = local.user_name
  path = "/"
}

resource "aws_iam_access_key" "demo" {
  user = aws_iam_user.demo.name
}

output "access_key" {
  value     = aws_iam_access_key.demo
  sensitive = true
}

resource "aws_iam_user_policy" "demo" {
  name   = "s3"
  user   = aws_iam_user.demo.name
  policy = data.aws_iam_policy_document.s3.json
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
