# module "cloudfront" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "3.4.0"

#   for_each = local.cloudfront_distribution
#   aliases  = each.value.aliases

#   enabled             = true
#   staging             = false # If you want to create a staging distribution, set this to true
#   http_version        = "http2and3"
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   wait_for_deployment = true
#   origin              = each.value.origin

#   default_cache_behavior = {
#     target_origin_id       = each.key
#     viewer_protocol_policy = "allow-all"
#     allowed_methods        = ["GET", "HEAD"]
#     cached_methods         = ["GET", "HEAD"]

#     use_forwarded_values = false
#     compress             = true
#     cache_policy_id      = "658327ea-f89d-4fab-a63d-7e88639e58f6"
#   }

#   # viewer_certificate = {
#   #   acm_certificate_arn            = aws_acm_certificate.this.arn
#   #   ssl_support_method             = "sni-only"
#   #   minimum_protocol_version       = "TLSv1.2_2021"
#   #   cloudfront_default_certificate = false
#   # }

#   depends_on = [helm_release.nginx-ingress-controller]
# }

# ######
# # ACM
# ######

# resource "aws_acm_certificate" "this" {
#   provider          = aws.virginia
#   domain_name       = "malik.vc"
#   validation_method = "DNS"
# }