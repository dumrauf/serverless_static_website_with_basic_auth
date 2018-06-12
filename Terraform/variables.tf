variable "region" {
  description = "The AWS region to use (currently only 'us-east-1' is supported by Lambda@Edge)"
  default     = "us-east-1"
}

variable "shared_credentials_file" {
  description = "The location of the AWS shared credentials file (e.g. ~dominic/.aws/credentials)"
}

variable "profile" {
  description = "The profile to use"
}

variable "hosted_zone_id" {
  description = "The hosted zone ID to use"
}

variable "subdomain_name" {
  description = "The subdomain to use"
}

variable "domain_name" {
  description = "The domain to use"
}

variable "acm_certificate_arn" {
  description = "The ARN of the certificate in the ACM to use for the serverless website"
}
