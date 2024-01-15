
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
