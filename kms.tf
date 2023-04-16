
resource "aws_kms_key" "kms_ebs" {
  description             = "KMS key for ebs"
  deletion_window_in_days = 30
}

resource "aws_kms_key_policy" "kms_policy_ebs" {
  key_id = aws_kms_key.kms_ebs.id
  policy = jsonencode({
    Id = "kms_policy_ebs"
    Statement = [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::100248794926:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
            "${aws_iam_role.EC2-CSYE6225.arn}"
          ]
        },
        "Action": [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Allow attachment of persistent resources",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::100248794926:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
            "${aws_iam_role.EC2-CSYE6225.arn}"
          ]
        },
        "Action": [
          "kms:CreateGrant"
        ],
        "Resource": "*",
        "Condition": {
          "Bool": {
            "kms:GrantIsForAWSResource": true
          }
        }
      },
    ]
    Version = "2012-10-17"
  })
}


resource "aws_kms_key" "kms_rds" {
  description             = "KMS key for rds"
  deletion_window_in_days = 30
}

resource "aws_kms_key_policy" "kms_policy_rds" {
  key_id = aws_kms_key.kms_rds.id
  policy = jsonencode({
    Id = "kms_policy_rds"
    Statement = [
      {
        Sid = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
        ]
        Resource = "*"
      },
      {
        Sid = "Allow access to RDS instance"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.kms_rds.arn
      }
    ]
    Version = "2012-10-17"
  })
}