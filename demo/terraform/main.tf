locals {
  user_name       = "demo"
  bucket_name     = "20230928-devopsdays-meetup-ehv"
  github_org      = "npalm"
  repository_name = "2023-09-28_devopsdays-meetup-ehv"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "demo" {
  bucket = local.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "demo" {
  bucket = aws_s3_bucket.demo.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "demo" {
  depends_on = [aws_s3_bucket_ownership_controls.demo]
  bucket     = aws_s3_bucket.demo.id
  acl        = "private"
}
