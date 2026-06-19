# -----------------------------------------------------------
# Enable Amazon Macie for the AWS account
# -----------------------------------------------------------
resource "aws_macie2_account" "macie" {
  status = "ENABLED"
}

# -----------------------------------------------------------
# Get current AWS Account ID
# -----------------------------------------------------------
data "aws_caller_identity" "current" {}

# -----------------------------------------------------------
# Macie Classification Job – ONE_TIME scan on the S3 bucket
# The job starts automatically as soon as it is created.
# -----------------------------------------------------------
resource "aws_macie2_classification_job" "scan_job" {
  name     = "macie-scan-job-v3-${random_string.suffix.result}"
  job_type = "ONE_TIME"

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.sensitive_data.bucket]
    }
  }

  sampling_percentage = 100

  tags = {
    Project = "CDO-Security-Macie-Lab"
  }

  depends_on = [
    aws_macie2_account.macie,
    aws_s3_object.dummy_data
  ]
}
