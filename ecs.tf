resource "aws_ecs_cluster" "this" {
  name = "saas-main-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  capacity_providers = ["FARGATE"]
  cluster_name       = resource.aws_ecs_cluster.this.name
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

resource "aws_iam_role_policy_attachment" "default" {
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

# * Step 7 - Run our application.
resource "aws_ecs_service" "this" {
  cluster         = resource.aws_ecs_cluster.this.id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = "${local.example}-service"
  task_definition = resource.aws_ecs_task_definition.this.arn

  lifecycle {
    ignore_changes = [desired_count] # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
  }

  load_balancer {
    container_name   = "cb-app"
    container_port   = 3000
    target_group_arn = resource.aws_lb_target_group.this.arn
  }

  network_configuration {
    security_groups = [
      resource.aws_security_group.egress_all.id,
      resource.aws_security_group.ingress_api.id,
    ]
    subnets          = resource.aws_subnet.private[*].id
    assign_public_ip = true
  }
}

# * Setup autoscaling policies
data "aws_arn" "this" { arn = resource.aws_ecs_service.this.id }
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = data.aws_arn.this.resource
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "scale-up-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = resource.aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = resource.aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = resource.aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 100

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "scale-up-policy-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = resource.aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = resource.aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = resource.aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    scale_in_cooldown  = 300
    scale_out_cooldown = 100
    target_value       = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_alb" {
  name               = "scale-up-policy-alb"
  policy_type        = "TargetTrackingScaling"
  resource_id        = resource.aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = resource.aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = resource.aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    scale_in_cooldown  = 300
    scale_out_cooldown = 100
    target_value       = 300

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${resource.aws_lb.this.arn_suffix}/${resource.aws_lb_target_group.this.arn_suffix}"
    }
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_service_out" {
  name               = "scale_service_out"
  service_namespace  = resource.aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = resource.aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = resource.aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = "cron(0 6 * * ? *)"

  scalable_target_action {
    max_capacity = 4
    min_capacity = 2
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_service_in" {
  name               = "scale_service_in"
  service_namespace  = resource.aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = resource.aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = resource.aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = "cron(0 18 * * ? *)"

  scalable_target_action {
    max_capacity = 2
    min_capacity = 1
  }
}