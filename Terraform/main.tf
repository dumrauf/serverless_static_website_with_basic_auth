module "serverless-static-website-with-basic-auth" {
  source = "modules/serverless-static-website-with-basic-auth"

  region                     = "${var.region}"
  hosted_zone_id             = "${var.hosted_zone_id}"
  subdomain_name             = "${var.subdomain_name}"
  domain_name                = "${var.domain_name}"
  acm_certificate_arn        = "${var.acm_certificate_arn}"
  logging_bucket_prefix      = "${var.logging_bucket_prefix}"
  logging_bucket_domain_name = "${var.logging_bucket_domain_name}"
}
