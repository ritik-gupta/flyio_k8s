module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.11.1"

  cluster_name = local.example

  # * Allocate 20% capacity to FARGATE and then split
  # * the remaining 80% capacity 50/50 between FARGATE
  # * and FARGATE_SPOT.
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        base   = 20
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}

data "aws_iam_policy_document" "this" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = resource.aws_iam_role.this.name
}

data "template_file" "cb_app" {
  template = file("./templates/app.json.tpl")

  vars = {
    app_image      = "${aws_ecr_repository.repository.repository_url}:latest"
    app_port       = 3000
    fargate_cpu    = 256
    fargate_memory = 512
    aws_region     = "eu-west-2"
    host_port      = 3000
  }
}

resource "aws_ecs_task_definition" "this" {
  container_definitions    = data.template_file.cb_app.rendered
  cpu                      = 256
  execution_role_arn       = resource.aws_iam_role.this.arn
  family                   = "family-of-${local.example}-tasks"
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_service" "this" {
  cluster         = module.ecs.cluster_id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = "${local.example}-service"
  task_definition = resource.aws_ecs_task_definition.this.arn

  lifecycle {
    ignore_changes = [desired_count] # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
  }

  load_balancer {
    container_name   = "cb-app"
    container_port   = local.container_port
    target_group_arn = module.alb.target_group_arns[0]
  }

  network_configuration {
    security_groups = [module.vpc.default_security_group_id]
    subnets         = module.vpc.private_subnets
  }
}
