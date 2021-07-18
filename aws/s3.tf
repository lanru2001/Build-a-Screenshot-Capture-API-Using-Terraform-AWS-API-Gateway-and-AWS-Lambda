# S3 bucket to store all of our screenshots

resource "aws_s3_bucket" "screenshot_bucket" {
  bucket        = "STORAGE_BUCKET_NAME"
  force_destroy = true
  acl = "public-read"

  versioning {
    enabled = false
  }
}
