resource "random_string" "tiny" {
  length  = 2
  special = false
}

data "aws_iam_policy_document" "lambda_execution_role_assume_role_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_execution_role_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

locals {
  fqdn                            = "${var.subdomain_name}.${var.domain_name}"
  fqdn_for_naming                 = "${var.subdomain_name}.${var.domain_name}---${random_string.tiny.result}"
  fqdn_dots_replaced_with_hyphens = "${var.subdomain_name}-${replace(var.domain_name, ".", "-")}"

  # Workaround for https://github.com/hashicorp/terraform/issues/15751
  lambda_execution_role_name = "${local.fqdn_for_naming}---lambda_execution_role"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = substr(
    local.lambda_execution_role_name,
    0,
    min(64, length(local.lambda_execution_role_name)),
  )

  assume_role_policy = data.aws_iam_policy_document.lambda_execution_role_assume_role_policy_document.json
  path               = "/service/"
  description        = "${local.fqdn} - Basic Auth @Edge Lambda Execution Role"
}

locals {
  # Workaround for https://github.com/hashicorp/terraform/issues/15751
  lambda_execution_role_policy_name = "${local.fqdn_for_naming}---lambda_execution_role_policy_document"
}

resource "aws_iam_role_policy" "lambda_execution_role_policy" {
  name = substr(
    local.lambda_execution_role_policy_name,
    0,
    min(128, length(local.lambda_execution_role_policy_name)),
  )
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.lambda_execution_role_policy_document.json
}

locals {
  basic_auth_at_edge_lambda_package_output_path = "${var.lambda_at_edge_code_artefacts_directory}/${local.fqdn}---${var.lambda_at_edge_code_package_name}.zip"

  # Workaround for https://github.com/hashicorp/terraform/issues/15751
  basic_auth_at_edge_lambda_function_name = "${local.fqdn_dots_replaced_with_hyphens}---${random_string.tiny.result}---BasicAuthAtEdgeLambda"
}

data "archive_file" "basic_auth_at_edge_lambda_package" {
  type        = "zip"
  source_dir  = "${path.root}/lambda-at-edge-code/${local.fqdn}/"
  output_path = local.basic_auth_at_edge_lambda_package_output_path
}

resource "aws_lambda_function" "basic_auth_at_edge_lambda" {
  filename = local.basic_auth_at_edge_lambda_package_output_path
  function_name = substr(
    local.basic_auth_at_edge_lambda_function_name,
    0,
    min(64, length(local.basic_auth_at_edge_lambda_function_name)),
  )
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.basic_auth_at_edge_lambda_package.output_base64sha256
  runtime          = "nodejs10.x"
  description      = "${local.fqdn} - Basic Auth @Edge Lambda"
  memory_size      = 128
  timeout          = 1
  publish          = true

  tags = {
    terraform                               = "true"
    servless-static-website-with-basic-auth = "${local.fqdn}"
  }
}

locals {
  # Workaround for https://github.com/hashicorp/terraform/issues/15751
  serverless_website_bucket_name = "${local.fqdn_dots_replaced_with_hyphens}"
}

resource "aws_s3_bucket" "serverless_website_bucket" {
  bucket = "${substr(
    local.serverless_website_bucket_name,
    0,
    min(53, length(local.serverless_website_bucket_name)),
  )}---contents"
  acl = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    terraform                               = "true"
    servless-static-website-with-basic-auth = "${local.fqdn}"
  }

  force_destroy = true
}

resource "aws_cloudfront_origin_access_identity" "cloudfront_origin_access_identity" {
  comment = "${local.fqdn} - Origin Access Identity for Serverless Static Website with Basic Auth"
}

data "aws_iam_policy_document" "serverless_website_bucket_policy" {
  statement {
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.serverless_website_bucket.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "AES256",
      ]
    }
  }

  statement {
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.serverless_website_bucket.arn}/*"]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "true",
      ]
    }
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity.iam_arn]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.serverless_website_bucket.arn}/*"]
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity.iam_arn]
    }

    actions   = ["s3:Listbucket"]
    resources = [aws_s3_bucket.serverless_website_bucket.arn]
  }
}

resource "aws_s3_bucket_policy" "serverless_website_bucket_policy" {
  bucket = aws_s3_bucket.serverless_website_bucket.id

  policy = data.aws_iam_policy_document.serverless_website_bucket_policy.json
}

resource "aws_cloudfront_distribution" "serverless_website_distribution" {
  aliases = ["${local.fqdn}"]

  origin {
    domain_name = aws_s3_bucket.serverless_website_bucket.bucket_domain_name
    origin_id   = "s3Origin"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity.id}"
    }
  }

  logging_config {
    bucket = var.log_bucket_domain_name

    prefix          = "${local.fqdn}/"
    include_cookies = true
  }

  enabled             = true
  comment             = "${local.fqdn} - Serverless Static Website with Basic Auth from S3 Origin"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    compress         = true
    default_ttl      = 16070400
    max_ttl          = 31536000
    min_ttl          = 2678400
    target_origin_id = "s3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.basic_auth_at_edge_lambda.qualified_arn
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    terraform                               = "true"
    servless-static-website-with-basic-auth = "${local.fqdn}"
  }
}

resource "aws_route53_record" "serverless_website_recordset_group" {
  zone_id = var.hosted_zone_id
  name    = "${local.fqdn}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.serverless_website_distribution.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

data "aws_iam_policy_document" "serverless_website_administrator_user_policy_document" {
  statement {
    effect = "Allow"

    actions = ["cloudfront:CreateInvalidation"]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.serverless_website_bucket.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
    ]

    resources = ["${aws_s3_bucket.serverless_website_bucket.arn}/*"]
  }
}

locals {
  # Workaround for https://github.com/hashicorp/terraform/issues/15751
  serverless_website_administrator_user_policy_name = "${local.fqdn_for_naming}---ServerlessWebsiteAdministratorUserPolicy"
}

resource "aws_iam_policy" "serverless_website_administrator_user_policy" {
  description = "${local.fqdn} - Policy for uploading objects to S3 bucket and invalidating CloudFront distribution"
  name = substr(
    local.serverless_website_administrator_user_policy_name,
    0,
    min(
      128,
      length(local.serverless_website_administrator_user_policy_name),
    ),
  )
  path   = "/service/"
  policy = data.aws_iam_policy_document.serverless_website_administrator_user_policy_document.json
}

locals {
  # Workaround for https://github.com/hashicorp/terraform/issues/15751
  serverless_website_administrator_user_name = "${local.fqdn_for_naming}---ServerlessWebsiteAdministrator"
}

resource "aws_iam_user" "serverless_website_administrator_user" {
  name = substr(
    local.serverless_website_administrator_user_name,
    0,
    min(64, length(local.serverless_website_administrator_user_name)),
  )
  path = "/service/"
}

resource "aws_iam_user_policy_attachment" "serverless_website_administrator_user_policy_attachment" {
  user       = aws_iam_user.serverless_website_administrator_user.name
  policy_arn = aws_iam_policy.serverless_website_administrator_user_policy.arn
}

