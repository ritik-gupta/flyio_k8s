resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "saasmaker-eks-${random_string.suffix.result}"

  cloudfront_distribution = {
    ritik = {
      # aliases = ["malik.vc"]
      # aliases = ["sachin.org.uk"]
      aliases = []
      origin = {
        "ritik" = {
          connection_attempts = 3
          connection_timeout  = 10
          origin_path         = "/ritik"
          domain_name         = data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.hostname
          custom_origin_config = {
            http_port                = 80
            https_port               = 443
            origin_keepalive_timeout = 5
            origin_protocol_policy   = "http-only"
            origin_read_timeout      = 30
            origin_ssl_protocols     = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
          }
        }
      }
    },
    #   vishal = {
    #     aliases = [""]
    #     origin = {
    #       "vishal" = {
    #         connection_attempts = 3
    #         connection_timeout  = 10
    #         origin_path         = "/vishal"
    #         domain_name         = data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.hostname
    #         custom_origin_config = {
    #           http_port                = 80
    #           https_port               = 443
    #           origin_keepalive_timeout = 5
    #           origin_protocol_policy   = "http-only"
    #           origin_read_timeout      = 30
    #           origin_ssl_protocols     = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    #         }
    #       }
    #     }
    #   }
  }
}
