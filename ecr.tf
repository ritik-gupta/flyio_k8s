resource "aws_ecr_repository" "repository" {
  name = "ritik-test-ecr"
  #   image_tag_mutability = "IMMUTABLE"
  #   image_scanning_configuration {
  #     scan_on_push = true
  #   }

  encryption_configuration {
    encryption_type = "KMS"
  }
  force_delete = true
}