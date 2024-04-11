data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "${helm_release.nginx-ingress-controller.name}-ingress-nginx-controller"
  }

  depends_on = [
    helm_release.nginx-ingress-controller
  ]
}

output "lb_hostname" {
  description = "The hostname of the load balancer"
  value       = data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.hostname
}