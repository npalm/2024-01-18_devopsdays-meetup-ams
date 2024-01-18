
data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.github_actions.certificates.*.sha1_fingerprint
}

resource "aws_iam_role" "github_actions" {
  name               = "demo"
  path               = "/github-actions/"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trusted_identity.json
}

data "aws_iam_policy_document" "github_actions_trusted_identity" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_org}/${local.repository_name}:environment:demo"]
    }
  }
}

resource "aws_iam_role_policy" "s3" {
  name   = "s3-policy"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.s3.json
}
