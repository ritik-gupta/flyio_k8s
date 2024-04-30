module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.9.0"

  load_balancer_type = "application"
  security_groups    = [module.vpc.default_security_group_id]
  subnets            = module.vpc.public_subnets
  vpc_id             = module.vpc.vpc_id

  security_group_ingress_rules = {
    all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      description = "HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  security_group_egress_rules = {
    all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  listeners = {
    ecs_listener = {
      # ! Defaults to "forward" action for "target group"
      # ! at index = 0 in "the target_groups" input below.
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  }

  target_groups = {
    ecs = {
      backend_port     = local.container_port
      backend_protocol = "HTTP"
      target_type      = "ip"
    }
  }
}
