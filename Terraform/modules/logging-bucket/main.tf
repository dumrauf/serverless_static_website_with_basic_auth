resource "aws_s3_bucket" "logging_bucket" {
  bucket_prefix = "${var.logging_bucket_prefix}"
  acl           = "log-delivery-write"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    terraform  = "true"
    log-bucket = "true"
  }
}
