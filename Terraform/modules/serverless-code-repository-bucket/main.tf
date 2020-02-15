resource "aws_s3_bucket" "serverless-code-repository-bucket" {
  bucket_prefix = "serverless-code-repository-"
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    terraform = "true"
    module    = "serverless-code-repository-bucket"
  }
}

resource "aws_s3_bucket_policy" "serverless-code-repository-bucket-policy" {
  bucket = aws_s3_bucket.serverless-code-repository-bucket.id

  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.serverless-code-repository-bucket.arn}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "AES256"
                }
            }
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.serverless-code-repository-bucket.arn}/*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": "true"
                }
            }
        }
    ]
}
POLICY

}

