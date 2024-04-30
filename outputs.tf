output "lb_url" {
  value = "http://${resource.aws_lb.this.dns_name}"
}
