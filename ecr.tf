# # tfsec:ignore:aws-ecr-repository-customer-key
# resource "aws_ecr_repository" "repository" {
#   name = var.repository_name
#   #   image_tag_mutability = "IMMUTABLE"
#   #   image_scanning_configuration {
#   #     scan_on_push = true
#   #   }

#   encryption_configuration {
#     encryption_type = "KMS"
#   }
#   force_delete = true
# }
