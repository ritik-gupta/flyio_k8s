output "lb_url" {
  value = "http://${module.alb.dns_name}"
}
