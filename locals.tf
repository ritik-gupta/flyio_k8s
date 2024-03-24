resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "saasmaker-eks-${random_string.suffix.result}"
}
