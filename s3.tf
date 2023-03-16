resource "random_id" "bucket_name" {
  byte_length = 8
}

resource "aws_s3_bucket" "new_bucket" {
  bucket        = lower("tf-${random_id.bucket_name.hex}")
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "transition-to-ia"
    prefix  = ""
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# output "bucket_name" {
#   value = aws_s3_bucket.new_bucket.bucket
# }

resource "aws_s3_bucket_public_access_block" "new_bucket" {
  bucket = aws_s3_bucket.new_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# create IAM policy
resource "aws_iam_policy" "WebAppS3" {
  name        = "WebAppS3"
  path        = "/"
  description = "IAM S3 policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.new_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.new_bucket.bucket}/*"
        ]
      }
    ]
  })
}

# create IAM role
resource "aws_iam_role" "EC2-CSYE6225" {
  name        = "EC2-CSYE6225"
  description = "test - access to source and destination S3 bucket"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "EC2-CSYE6225" {
  role       = aws_iam_role.EC2-CSYE6225.name
  policy_arn = aws_iam_policy.WebAppS3.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.EC2-CSYE6225.name
}