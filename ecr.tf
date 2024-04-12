# tfsec:ignore:aws-ecr-repository-customer-key
resource "aws_ecr_repository" "repository" {
  name = "aws-eks-quarkus-example"

  encryption_configuration {
    encryption_type = "KMS"
  }
  force_delete = true
}
