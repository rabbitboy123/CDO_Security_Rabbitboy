# -----------------------------------------------------------
# Random suffix to ensure globally unique S3 bucket name
# -----------------------------------------------------------
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# -----------------------------------------------------------
# S3 Bucket to store data that Macie will scan
# -----------------------------------------------------------
resource "aws_s3_bucket" "sensitive_data" {
  bucket        = "${var.bucket_prefix}-${random_string.suffix.result}"
  force_destroy = true

  tags = {
    Project = "CDO-Security-Macie-Lab"
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.sensitive_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload the dummy sensitive data CSV into the bucket
resource "aws_s3_object" "dummy_data" {
  bucket = aws_s3_bucket.sensitive_data.id
  key    = "dummy_sensitive_data_v3.csv"
  source = "${path.module}/dummy_sensitive_data.csv"
  etag   = filemd5("${path.module}/dummy_sensitive_data.csv")

  depends_on = [aws_s3_bucket_public_access_block.block]
}
