output "logging_bucket_domain_name" {
  value = "${aws_s3_bucket.logging_bucket.bucket_domain_name}"
}
