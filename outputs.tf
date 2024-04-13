# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

# output "acm_certificate_domain_validation_options" {
#   value = aws_acm_certificate.this.domain_validation_options
# }

# output "cert_status" {
#   value = aws_acm_certificate.this.status
# }
