data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = helm_release.nginx-ingress-controller.status[0].resources[0].name
  }

  depends_on = [
    helm_release.nginx-ingress-controller
  ]
}

output "lb_hostname" {
  description = "The hostname of the load balancer"
  value       = data.kubernetes_service.nginx_ingress.load_balancer_ingress[0].hostname
}