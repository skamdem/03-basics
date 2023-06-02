# resources of aws provider

# versioned and encrypted s3 Bucket is used for storage
resource "aws_s3_bucket" "tf_remote_state_bucket" {
  bucket = "devops-demos-terraform-state-bucket"
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning so we can see the full revision history of our
# state files
resource "aws_s3_bucket_versioning" "tf_remote_state_bucket" {
  bucket = aws_s3_bucket.tf_remote_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_remote_state_bucket" {
  bucket = aws_s3_bucket.tf_remote_state_bucket.id
  rule {
    id     = "rax-cleanup-incomplete-mpu-objects"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    filter {
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.tf_remote_state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_remote_state_bucket" {
  bucket = aws_s3_bucket.tf_remote_state_bucket.id
  # Enable server-side encryption by default
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB is used for locking
resource "aws_dynamodb_table" "tf_remote_state_bucket_locking" {
  hash_key     = "LockID"
  name         = "devops-demos-tfstate-lock"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}