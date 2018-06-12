variable "region" {
  type        = "string"
  description = "AWS region to deploy to"
  default     = "us-east-1"
}

variable "hosted_zone_id" {
  type        = "string"
  description = "ID of the Route 53 hosted zone to use"
}

variable "subdomain_name" {
  type        = "string"
  description = "Name of the subdomain to create in Route 53"
}

variable "domain_name" {
  type        = "string"
  description = "Name of the domain to use in Route 53"
}

variable "acm_certificate_arn" {
  type        = "string"
  description = "The ARN of the ACM certificate to use for the CloudFront distribution (must match a superset of the subdomain.domain to be created in Route 53)"
}

variable "lambda_at_edge_code_package_name" {
  type        = "string"
  description = "The name to use for the lambda@Edge code package"
  default     = "lambda_at_edge_code_package.zip"
}

variable "lambda_at_edge_code_artefacts_directory" {
  type        = "string"
  description = "The directory to use when creating the lambda@Edge code package"
  default     = ".artefacts"
}
