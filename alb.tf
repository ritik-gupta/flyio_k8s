resource "aws_lb" "this" {
  load_balancer_type = "application"

  depends_on = [resource.aws_internet_gateway.this]

  security_groups = [
    resource.aws_security_group.egress_all.id,
    resource.aws_security_group.http.id,
    resource.aws_security_group.https.id,
  ]

  subnets = resource.aws_subnet.public[*].id
}

resource "aws_lb_target_group" "this" {
  port        = local.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = resource.aws_vpc.this.id

  depends_on = [resource.aws_lb.this]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = resource.aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}
