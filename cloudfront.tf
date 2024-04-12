module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.0"

  for_each = local.cloudfront_distribution
  aliases  = each.value.aliases

  enabled             = true
  staging             = false # If you want to create a staging distribution, set this to true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = true
  origin              = each.value.origin

  default_cache_behavior = {
    target_origin_id       = each.key
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    use_forwarded_values = false
    compress             = true
    cache_policy_id      = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  viewer_certificate = {
    acm_certificate_arn            = aws_acm_certificate.this.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }

  depends_on = [ helm_release.nginx-ingress-controller ]
}

######
# ACM
######

resource "aws_acm_certificate" "this" {
  provider = aws.virginia
  domain_name = "malik.vc"
  validation_method = "DNS"
}

# # data "aws_route53_zone" "this" {
# #   name = local.domain_name
# # }

# # module "acm" {
# #   source  = "terraform-aws-modules/acm/aws"
# #   version = "~> 4.0"

# #   domain_name               = local.domain_name
# #   zone_id                   = data.aws_route53_zone.this.id
# #   subject_alternative_names = ["${local.subdomain}.${local.domain_name}"]
# # }

# #############
# # S3 buckets
# #############

# # data "aws_canonical_user_id" "current" {}
# # data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

# # module "s3_one" {
# #   source  = "terraform-aws-modules/s3-bucket/aws"
# #   version = "~> 4.0"

# #   bucket        = "s3-one-${random_pet.this.id}"
# #   force_destroy = true
# # }

# # module "log_bucket" {
# #   source  = "terraform-aws-modules/s3-bucket/aws"
# #   version = "~> 4.0"

# #   bucket = "logs-${random_pet.this.id}"

# #   control_object_ownership = true
# #   object_ownership         = "ObjectWriter"

# #   grant = [{
# #     type       = "CanonicalUser"
# #     permission = "FULL_CONTROL"
# #     id         = data.aws_canonical_user_id.current.id
# #     }, {
# #     type       = "CanonicalUser"
# #     permission = "FULL_CONTROL"
# #     id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
# #     # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
# #     # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
# #   }]
# #   force_destroy = true
# # }

# # #############################################
# # # Using packaged function from Lambda module
# # #############################################

# # locals {
# #   package_url = "https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-lambda/master/examples/fixtures/python3.8-zip/existing_package.zip"
# #   downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
# # }

# # resource "null_resource" "download_package" {
# #   triggers = {
# #     downloaded = local.downloaded
# #   }

# #   provisioner "local-exec" {
# #     command = "curl -L -o ${local.downloaded} ${local.package_url}"
# #   }
# # }

# # module "lambda_function" {
# #   source  = "terraform-aws-modules/lambda/aws"
# #   version = "~> 7.0"

# #   function_name = "${random_pet.this.id}-lambda"
# #   description   = "My awesome lambda function"
# #   handler       = "index.lambda_handler"
# #   runtime       = "python3.8"

# #   publish        = true
# #   lambda_at_edge = true

# #   create_package         = false
# #   local_existing_package = local.downloaded

# #   # @todo: Missing CloudFront as allowed_triggers?

# #   #    allowed_triggers = {
# #   #      AllowExecutionFromAPIGateway = {
# #   #        service = "apigateway"
# #   #        arn     = module.api_gateway.apigatewayv2_api_execution_arn
# #   #      }
# #   #    }
# # }

# # ##########
# # # Route53
# # ##########

# # module "records" {
# #   source  = "terraform-aws-modules/route53/aws//modules/records"
# #   version = "~> 2.0"

# #   zone_id = data.aws_route53_zone.this.zone_id

# #   records = [
# #     {
# #       name = local.subdomain
# #       type = "A"
# #       alias = {
# #         name    = module.cloudfront.cloudfront_distribution_domain_name
# #         zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
# #       }
# #     },
# #   ]
# # }

# # data "aws_iam_policy_document" "s3_policy" {
# #   # Origin Access Identities
# #   statement {
# #     actions   = ["s3:GetObject"]
# #     resources = ["${module.s3_one.s3_bucket_arn}/static/*"]

# #     principals {
# #       type        = "AWS"
# #       identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
# #     }
# #   }

# #   # Origin Access Controls
# #   statement {
# #     actions   = ["s3:GetObject"]
# #     resources = ["${module.s3_one.s3_bucket_arn}/static/*"]

# #     principals {
# #       type        = "Service"
# #       identifiers = ["cloudfront.amazonaws.com"]
# #     }

# #     condition {
# #       test     = "StringEquals"
# #       variable = "aws:SourceArn"
# #       values   = [module.cloudfront.cloudfront_distribution_arn]
# #     }
# #   }
# # }

# # resource "aws_s3_bucket_policy" "bucket_policy" {
# #   bucket = module.s3_one.s3_bucket_id
# #   policy = data.aws_iam_policy_document.s3_policy.json
# # }

# # ########
# # # Extra
# # ########

# # resource "random_pet" "this" {
# #   length = 2
# # }

# # # resource "aws_cloudfront_function" "example" {
# # #   name    = "example-${random_pet.this.id}"
# # #   runtime = "cloudfront-js-1.0"
# # #   code    = file("${path.module}/example-function.js")
# # # }