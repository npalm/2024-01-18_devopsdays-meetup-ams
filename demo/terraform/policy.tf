data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [aws_s3_bucket.demo.arn, "${aws_s3_bucket.demo.arn}/*"]
  }
}
