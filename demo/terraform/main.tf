locals {
  user_name              = "demo"
  bucket_name            = "20240118-devopsdays-meetup-ams"
  github_org             = "npalm"
  repository_name        = "2024-01-18_devopsdays-meetup-ams"
  repository_environment = "demo"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "demo" {
  bucket        = local.bucket_name
  force_destroy = true

  lifecycle {
    prevent_destroy = false
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
