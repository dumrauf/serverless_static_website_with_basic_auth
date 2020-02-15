output "serverless_website_bucket_name" {
  value = aws_s3_bucket.serverless_website_bucket.id
}

output "serverless_website_distribution_id" {
  value = aws_cloudfront_distribution.serverless_website_distribution.id
}

